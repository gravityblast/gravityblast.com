# Turn a post into an MP3 narration with Gemini text-to-speech.
#
#   bundle exec ruby script/narrate.rb _posts/2026-11-20-some-post.md
#
# Options:
#   --voice NAME      Gemini prebuilt voice (default: Sulafat, a warm female voice)
#   --model NAME      TTS model (default: $GEMINI_TTS_MODEL or gemini-3.8-flash-tts)
#   --dry-run         print the text that would be read, call nothing
#   --sample          synthesize only the opening (~800 chars) to audition a voice
#   --pace N          even out speed: retime every chunk to N characters/second
#                     without changing pitch (default: 16; 0 keeps Gemini's pace)
#   --list-models     list the TTS models your key can use
#   --check           verify every post with `audio:` still matches its narration
#                     (used in CI; no API key or network needed)
#
# The API key is read from GRAVITYBLAST_COM_GEMINI_API_KEY or GEMINI_API_KEY, or from a gitignored .env file in the
# repo root (GEMINI_API_KEY=...). Each chunk's audio is cached in .narrate-cache/,
# keyed by model + voice + text, so re-running only pays for changed paragraphs.
#
# Output: assets/audio/<post-slug>.mp3 (mono, 64 kbps) plus <post-slug>.json with
# the waveform peaks the player draws. Add the printed `audio:` line to the
# post's front matter to show the player.
#
# Only the post text is sent: TTS models may read any instructions aloud.

require "kramdown"
require "kramdown-parser-gfm"
require "net/http"
require "json"
require "base64"
require "digest"
require "fileutils"
require "optparse"
require "yaml"
require "open3"

ROOT = File.expand_path("..", __dir__)
CACHE_DIR = File.join(ROOT, ".narrate-cache")
AUDIO_DIR = File.join(ROOT, "assets", "audio")
API = "https://generativelanguage.googleapis.com/v1beta"
CHUNK_CHARS = 3_500
PAUSE_SECONDS = 0.6
SAMPLE_CHARS = 800
PEAKS = 180

# ---------------------------------------------------------------- setup

opts = { voice: "Sulafat", model: nil, dry_run: false, sample: false, list: false, pace: 16.0 }
OptionParser.new do |o|
  o.banner = "usage: bundle exec ruby script/narrate.rb [options] _posts/<post>.md"
  o.on("--voice NAME") { |v| opts[:voice] = v }
  o.on("--model NAME") { |v| opts[:model] = v }
  o.on("--dry-run") { opts[:dry_run] = true }
  o.on("--sample") { opts[:sample] = true }
  o.on("--list-models") { opts[:list] = true }
  o.on("--pace N", Float) { |v| opts[:pace] = v }
  o.on("--check") { opts[:check] = true }
end.parse!

def load_env
  path = File.join(ROOT, ".env")
  return unless File.exist?(path)
  File.foreach(path) do |line|
    next if line.strip.empty? || line.start_with?("#")
    key, value = line.strip.split("=", 2)
    ENV[key] ||= value.to_s.delete_prefix('"').delete_suffix('"') if key && value
  end
end

load_env
API_KEY = ENV["GRAVITYBLAST_COM_GEMINI_API_KEY"] || ENV["GEMINI_API_KEY"]
MODEL = opts[:model] || ENV["GEMINI_TTS_MODEL"] || "gemini-3.8-flash-tts"

def api_key!
  abort "GEMINI_API_KEY not set (export it, or put GEMINI_API_KEY=... in .env)" unless API_KEY && !API_KEY.empty?
  API_KEY
end

def request(method, path, body = nil)
  uri = URI("#{API}/#{path}")
  req = method == :get ? Net::HTTP::Get.new(uri) : Net::HTTP::Post.new(uri)
  req["x-goog-api-key"] = api_key!
  req["Content-Type"] = "application/json"
  req.body = JSON.generate(body) if body
  Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 300) { |h| h.request(req) }
end

if opts[:list]
  res = request(:get, "models?pageSize=1000")
  abort "#{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
  JSON.parse(res.body)["models"].map { |m| m["name"].delete_prefix("models/") }
      .select { |n| n.include?("tts") }.each { |n| puts n }
  exit
end

# ---------------------------------------------------------------- markdown -> spoken text

SYMBOLS = { lsquo: "‘", rsquo: "’", ldquo: "“", rdquo: "”", hellip: "…", mdash: " — ",
            ndash: " – ", laquo: "«", raquo: "»", laquo_space: "« ", raquo_space: " »" }.freeze

def inline_text(el)
  case el.type
  when :text then el.value
  when :codespan then el.value
  when :smart_quote, :typographic_sym then SYMBOLS.fetch(el.value, "")
  when :entity then el.value.char
  when :br then " "
  when :img, :footnote, :html_element, :math then ""
  else el.children.map { |c| inline_text(c) }.join
  end
end

def blocks(el, out = [])
  el.children.each do |c|
    case c.type
    when :header
      out << "#{inline_text(c).strip}."
    when :p
      t = inline_text(c).gsub(/\s+/, " ").strip
      out << t unless t.empty?
    when :ul, :ol
      c.children.each do |li|
        t = li.children.map { |x| x.type == :p ? inline_text(x) : (%i[ul ol].include?(x.type) ? "" : inline_text(x)) }
              .join(" ").gsub(/\s+/, " ").strip
        out << (t.match?(/[.!?:]\z/) ? t : "#{t}.") unless t.empty?
        li.children.select { |x| %i[ul ol].include?(x.type) }.each { |sub| blocks(Kramdown::Element.new(:root).tap { |r| r.children << sub }, out) }
      end
    when :blockquote
      blocks(c, out)
    when :codeblock, :table, :hr, :html_element, :math, :blank, :xml_comment
      next
    end
  end
  out
end

# The exact paragraphs that get narrated, in order (title first).
def spoken_paragraphs(path)
  source = File.read(path)
  front_matter = {}
  if source.start_with?("---")
    _, fm, body = source.split(/^---\s*$/, 3)
    front_matter = YAML.safe_load(fm, permitted_classes: [Date, Time]) || {}
    source = body
  end
  source = source.gsub(/\{%.*?%\}|\{\{.*?\}\}/m, "") # drop Liquid tags

  paragraphs = blocks(Kramdown::Document.new(source, input: "GFM", hard_wrap: false).root)
  title = front_matter["title"].to_s.strip
  paragraphs.unshift("#{title}.") unless title.empty?
  [paragraphs, front_matter]
end

# Fingerprint of the narrated text, stored in the waveform JSON so --check can
# tell whether a post changed after its audio was generated.
def text_fingerprint(paragraphs)
  Digest::SHA256.hexdigest(paragraphs.join("\n\n"))
end

# ---------------------------------------------------------------- --check (CI)

if opts[:check]
  problems = []
  checked = 0
  Dir[File.join(ROOT, "_posts", "*.{md,markdown}")].sort.each do |path|
    paragraphs, fm = spoken_paragraphs(path)
    audio = fm["audio"] or next
    checked += 1
    name = path.delete_prefix("#{ROOT}/")
    mp3 = File.join(ROOT, audio.delete_prefix("/"))
    json = mp3.sub(/\.mp3\z/, ".json")
    if !File.exist?(mp3)
      problems << "#{name}: audio file #{audio} is missing"
    elsif !File.exist?(json)
      problems << "#{name}: #{json.delete_prefix("#{ROOT}/")} is missing"
    elsif JSON.parse(File.read(json))["text_sha256"] != text_fingerprint(paragraphs)
      problems << "#{name}: text changed since its audio was generated"
    end
  end
  if problems.empty?
    puts "Narration check: #{checked} narrated post(s), all up to date."
    exit
  end
  warn "Narration check failed:"
  problems.each { |p| warn "  - #{p}" }
  warn "Regenerate locally with: bundle exec ruby script/narrate.rb <post>"
  exit 1
end

post_path = ARGV.first or abort "usage: bundle exec ruby script/narrate.rb [options] _posts/<post>.md"
paragraphs, front_matter = spoken_paragraphs(post_path)

chunks = paragraphs.each_with_object([+""]) do |p, acc|
  acc << +"" if !acc.last.empty? && acc.last.size + p.size + 2 > CHUNK_CHARS
  acc.last << (acc.last.empty? ? p : "\n\n#{p}")
end.reject(&:empty?)
if opts[:sample]
  sample = paragraphs.each_with_object([]) { |p, acc| acc << p if acc.sum(&:size) < SAMPLE_CHARS }
  chunks = [sample.join("\n\n")]
end

chars = chunks.sum(&:size)
puts "#{paragraphs.size} paragraphs, #{chunks.size} chunk(s), #{chars} characters"

if opts[:dry_run]
  chunks.each_with_index { |c, i| puts "\n--- chunk #{i + 1} (#{c.size} chars) ---\n#{c}" }
  exit
end

# ---------------------------------------------------------------- synthesis

FileUtils.mkdir_p(CACHE_DIR)

def synthesize(text, voice)
  key = Digest::SHA256.hexdigest([MODEL, voice, text].join("\0"))
  cached = File.join(CACHE_DIR, "#{key}.pcm")
  return [File.binread(cached), 24_000, true] if File.exist?(cached)

  body = {
    contents: [{ parts: [{ text: text }] }],
    generationConfig: {
      responseModalities: ["AUDIO"],
      speechConfig: { voiceConfig: { prebuiltVoiceConfig: { voiceName: voice } } }
    }
  }

  attempts = 0
  begin
    attempts += 1
    res = request(:post, "models/#{MODEL}:generateContent", body)
    raise "retryable #{res.code}" if res.code == "429" || res.code.start_with?("5")
    abort "Gemini error #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
  rescue RuntimeError, Net::ReadTimeout, Errno::ECONNRESET => e
    raise if attempts >= 4 || !e.message.start_with?("retryable") && e.is_a?(RuntimeError)
    sleep(2**attempts)
    retry
  end

  part = JSON.parse(res.body).dig("candidates", 0, "content", "parts")&.find { |p| p["inlineData"] }
  abort "No audio in response: #{res.body[0, 500]}" unless part
  rate = part["inlineData"]["mimeType"][/rate=(\d+)/, 1]&.to_i || 24_000
  pcm = Base64.decode64(part["inlineData"]["data"])
  File.binwrite(cached, pcm)
  [pcm, rate, false]
end

# Each chunk is a separate request and Gemini picks a slightly different speed
# each time, so retime every chunk to the same characters/second. ffmpeg's
# atempo changes speed without changing pitch.
def retime(pcm, rate, chars, pace)
  seconds = pcm.bytesize / 2.0 / rate
  factor = (pace / (chars / seconds)).clamp(0.8, 1.25)
  print format(", %.1f chars/s → x%.2f", chars / seconds, factor)
  return pcm if (factor - 1).abs < 0.01
  out, status = Open3.capture2("ffmpeg", "-loglevel", "error", "-f", "s16le", "-ar", rate.to_s, "-ac", "1",
                               "-i", "pipe:0", "-filter:a", "atempo=#{factor.round(4)}",
                               "-f", "s16le", "-ar", rate.to_s, "-ac", "1", "pipe:1",
                               stdin_data: pcm, binmode: true)
  abort "ffmpeg atempo failed" unless status.success?
  out
end

pcm = +"".b
rate = 24_000
chunks.each_with_index do |chunk, i|
  print "chunk #{i + 1}/#{chunks.size} (#{chunk.size} chars)… "
  audio, rate, hit = synthesize(chunk, opts[:voice])
  print hit ? "cached" : "done"
  audio = retime(audio, rate, chunk.size, opts[:pace]) if opts[:pace].positive?
  puts
  pcm << audio
  pcm << ("\0".b * (rate * 2 * PAUSE_SECONDS).to_i) unless i == chunks.size - 1 # 16-bit mono
end

# ---------------------------------------------------------------- encode

slug = File.basename(post_path, ".*").sub(/\A\d{4}-\d{2}-\d{2}-/, "")
slug += "-sample-#{opts[:voice].downcase}" if opts[:sample]
FileUtils.mkdir_p(AUDIO_DIR)
out = File.join(AUDIO_DIR, "#{slug}.mp3")
raw = File.join(CACHE_DIR, "#{slug}.raw")
File.binwrite(raw, pcm)
ok = system("ffmpeg", "-loglevel", "error", "-y", "-f", "s16le", "-ar", rate.to_s, "-ac", "1",
            "-i", raw, "-codec:a", "libmp3lame", "-b:a", "64k", out)
File.delete(raw)
abort "ffmpeg failed" unless ok

seconds = pcm.bytesize / 2.0 / rate

# Waveform for the player: RMS loudness of PEAKS equal slices, normalized 0..1.
samples = pcm.unpack("s<*")
slice = [samples.size / PEAKS, 1].max
rms = Array.new(PEAKS) do |i|
  part = samples[i * slice, slice] || []
  part.empty? ? 0.0 : Math.sqrt(part.sum { |v| v * v } / part.size.to_f)
end
top = rms.max.to_f.nonzero? || 1.0
peaks = rms.map { |v| (v / top).round(3) }
File.write(out.sub(/\.mp3\z/, ".json"),
           JSON.generate(text_sha256: text_fingerprint(paragraphs), voice: opts[:voice], model: MODEL,
                         duration: seconds.round(2), peaks: peaks))
puts format("\nWrote %s (%.1f MB, %d:%02d)", out.delete_prefix("#{ROOT}/"), File.size(out) / 1e6, seconds / 60, seconds % 60)
puts "Add to the post's front matter:\n  audio: /assets/audio/#{slug}.mp3" unless opts[:sample]
