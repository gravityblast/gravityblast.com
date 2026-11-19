// Waveform audio player for post narrations.
//
// Progressive enhancement: the page ships a native <audio controls>. This
// script hides it and builds a custom player (play button, clickable
// waveform, time, speed). Waveform peaks come from the JSON file that
// script/narrate.rb writes next to the MP3.
(function () {
  "use strict";

  var SPEEDS = [1, 1.25, 1.5, 1.75, 2];
  var BAR = 2, GAP = 2;

  function fmt(t) {
    if (!isFinite(t) || t < 0) t = 0;
    var m = Math.floor(t / 60), s = Math.floor(t % 60);
    return m + ":" + (s < 10 ? "0" : "") + s;
  }

  // Resample peaks to `n` bars, keeping the loudest value of each range.
  function resample(peaks, n) {
    var out = new Array(n);
    for (var i = 0; i < n; i++) {
      var a = Math.floor(i * peaks.length / n);
      var b = Math.max(a + 1, Math.floor((i + 1) * peaks.length / n));
      var max = 0;
      for (var j = a; j < b; j++) if (peaks[j] > max) max = peaks[j];
      out[i] = max;
    }
    return out;
  }

  function setup(root) {
    var audio = root.querySelector("audio");
    var ui = root.querySelector(".ap-ui");
    var play = root.querySelector(".ap-play");
    var wave = root.querySelector(".ap-wave");
    var canvas = wave.querySelector("canvas");
    var time = root.querySelector(".ap-time");
    var speed = root.querySelector(".ap-speed");
    var ctx = canvas.getContext("2d");
    var peaks = null, bars = [], hover = -1, raf = 0, duration = 0;

    var css = getComputedStyle(root);
    var colors = {
      played: css.getPropertyValue("--ap-played").trim() || "#b4472c",
      rest: css.getPropertyValue("--ap-rest").trim() || "#d9d5cc",
      hover: css.getPropertyValue("--ap-hover").trim() || "#e3b3a5"
    };

    function dur() { return duration || audio.duration || 0; }

    function layout() {
      var w = wave.clientWidth, h = wave.clientHeight, dpr = window.devicePixelRatio || 1;
      canvas.width = Math.round(w * dpr);
      canvas.height = Math.round(h * dpr);
      canvas.style.width = w + "px";
      canvas.style.height = h + "px";
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      var n = Math.max(1, Math.floor((w + GAP) / (BAR + GAP)));
      bars = peaks ? resample(peaks, n) : new Array(n).fill(0.25);
      draw();
    }

    function draw() {
      var w = wave.clientWidth, h = wave.clientHeight;
      var progress = dur() ? audio.currentTime / dur() : 0;
      ctx.clearRect(0, 0, w, h);
      for (var i = 0; i < bars.length; i++) {
        var x = i * (BAR + GAP);
        var bh = Math.max(2, bars[i] * h);
        var pos = (x + BAR / 2) / w;
        ctx.fillStyle = pos <= progress ? colors.played
          : (hover >= 0 && pos <= hover ? colors.hover : colors.rest);
        ctx.fillRect(x, (h - bh) / 2, BAR, bh);
      }
      time.textContent = fmt(audio.currentTime) + " / " + fmt(dur());
      wave.setAttribute("aria-valuenow", Math.round(audio.currentTime));
      wave.setAttribute("aria-valuetext", fmt(audio.currentTime) + " of " + fmt(dur()));
    }

    function tick() {
      draw();
      if (!audio.paused) raf = requestAnimationFrame(tick);
    }

    function ratioAt(e) {
      var r = wave.getBoundingClientRect();
      return Math.min(1, Math.max(0, (e.clientX - r.left) / r.width));
    }

    function seek(ratio) {
      if (!dur()) return;
      audio.currentTime = ratio * dur();
      draw();
    }

    // Switch from native controls to the custom player.
    audio.controls = false;
    root.classList.add("is-ready");
    ui.hidden = false;

    play.addEventListener("click", function () {
      if (audio.paused) audio.play(); else audio.pause();
    });

    audio.addEventListener("play", function () {
      root.classList.add("is-playing");
      play.setAttribute("aria-label", "Pause");
      cancelAnimationFrame(raf);
      tick();
    });
    audio.addEventListener("pause", function () {
      root.classList.remove("is-playing");
      play.setAttribute("aria-label", "Play");
      draw();
    });
    audio.addEventListener("ended", function () { audio.currentTime = 0; draw(); });
    audio.addEventListener("loadedmetadata", function () {
      wave.setAttribute("aria-valuemax", Math.round(dur()));
      draw();
    });
    audio.addEventListener("seeked", draw);

    var dragging = false;
    wave.addEventListener("pointerdown", function (e) {
      dragging = true;
      wave.setPointerCapture(e.pointerId);
      seek(ratioAt(e));
    });
    wave.addEventListener("pointermove", function (e) {
      if (dragging) seek(ratioAt(e));
      else if (e.pointerType === "mouse") { hover = ratioAt(e); draw(); }
    });
    wave.addEventListener("pointerup", function () { dragging = false; });
    wave.addEventListener("pointerleave", function () { hover = -1; draw(); });
    wave.addEventListener("keydown", function (e) {
      var step = { ArrowLeft: -5, ArrowRight: 5, PageDown: -30, PageUp: 30 }[e.key];
      if (step) { e.preventDefault(); audio.currentTime = Math.max(0, Math.min(dur(), audio.currentTime + step)); draw(); }
      if (e.key === "Home") { e.preventDefault(); seek(0); }
      if (e.key === "End") { e.preventDefault(); seek(1); }
    });

    speed.addEventListener("click", function () {
      var i = (SPEEDS.indexOf(audio.playbackRate) + 1) % SPEEDS.length;
      audio.playbackRate = SPEEDS[i];
      speed.textContent = SPEEDS[i] + "×";
    });

    if ("ResizeObserver" in window) new ResizeObserver(layout).observe(wave);
    else window.addEventListener("resize", layout);
    layout();

    var src = root.getAttribute("data-peaks");
    if (src) {
      fetch(src).then(function (r) { return r.ok ? r.json() : null; }).then(function (data) {
        if (!data) return;
        // Speech is evenly loud, so stretch the range to show its rhythm.
        var lo = Math.min.apply(null, data.peaks), hi = Math.max.apply(null, data.peaks);
        peaks = data.peaks.map(function (v) {
          var t = hi > lo ? (v - lo) / (hi - lo) : 0.5;
          return 0.18 + 0.82 * Math.pow(t, 1.6);
        });
        duration = data.duration || 0;
        wave.setAttribute("aria-valuemax", Math.round(duration));
        layout();
      }).catch(function () {});
    }
  }

  document.querySelectorAll(".audio-player").forEach(setup);
})();
