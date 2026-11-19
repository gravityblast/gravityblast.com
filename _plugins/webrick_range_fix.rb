# Fix audio/video streaming on the local dev server (`jekyll serve`).
#
# WEBrick answers a Range request that carries If-Range (or If-None-Match /
# If-Modified-Since) with "304 Not Modified" and an empty body. Per RFC 9110 a
# matching If-Range must get 206 Partial Content. Browsers send If-Range while
# streaming media, so narrations stopped a few seconds in with a network error.
#
# Only the local server is affected; GitHub Pages answers 206 correctly. This
# file changes nothing in the generated site.
require "webrick"

module WebrickRangeFix
  def not_modified?(req, res, mtime, etag)
    return false if req["range"] # always serve the requested bytes
    super
  end
end

WEBrick::HTTPServlet::DefaultFileHandler.prepend(WebrickRangeFix)
