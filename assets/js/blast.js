// Blast, the site astronaut: floats in the right margin of posts and reacts
// to the reader without getting in the way.
//   - travels a dotted route down the margin with reading progress, landing
//     on a little planet at the end; hover shows the minutes left
//   - headphones + music notes while the narration plays
//   - dozes off after 40s of inactivity
//   - celebrates once when you reach the end of the post
//   - boot thrusters while descending, jetpack while climbing (scrolling)
//   - waves on hover, jetpack loop on click
// Only shown when the window is wide enough for an empty margin (CSS).
(function () {
  "use strict";

  var space = document.querySelector(".blast-space");
  var root = document.querySelector(".blast");
  var article = document.querySelector(".post-template .post");
  if (!space || !root || !article) return;

  var body = root.querySelector(".blast-body");
  var tip = root.querySelector(".blast-tip");
  var content = article.querySelector(".post-content") || article;
  var minutes = Math.max(1, Math.round(content.textContent.trim().split(/\s+/).length / 220));
  var end = document.querySelector(".post-end");
  var reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var IDLE_MS = 40000;
  var idleTimer = 0, busy = false, celebrated = false, ticking = false;

  function setState(name, on) { root.classList.toggle("is-" + name, on); }

  // ---- drift with reading progress (top 16% → 72% of the viewport)
  function place() {
    ticking = false;
    // 0 at the top of the page, 1 once the end of the article is in view.
    // Short posts that fit on screen are already "read": p = 1.
    var doc = document.documentElement;
    var scrollY = window.scrollY || doc.scrollTop;
    var articleEnd = article.getBoundingClientRect().bottom + scrollY;
    var span = Math.min(articleEnd - window.innerHeight, doc.scrollHeight - window.innerHeight);
    var p = span <= 1 ? 1 : Math.min(1, Math.max(0, scrollY / span));
    var y = window.innerHeight * (0.16 + 0.56 * p);
    space.style.setProperty("--blast-y", Math.round(y) + "px");
    space.style.setProperty("--blast-p", p.toFixed(4));
    fly(p);
    space.classList.toggle("is-arrived", p > 0.995);
    var left = Math.ceil(minutes * (1 - p) - 0.05);
    tip.textContent = p > 0.995 ? "You made it" : left <= 1 ? "Almost there" : left + " min left";
  }
  // ---- thrusters while Blast is actually moving (boots down, jetpack up)
  var lastP = -1, flyTimer = 0;
  function fly(p) {
    var prev = lastP;
    lastP = p;
    if (prev < 0 || Math.abs(p - prev) < 0.0005) return;
    setState("down", p > prev);
    setState("up", p < prev);
    setState("flying", true);
    clearTimeout(flyTimer);
    flyTimer = setTimeout(function () { setState("flying", false); }, 260);
  }
  function onScroll() {
    wake();
    if (!ticking) { ticking = true; requestAnimationFrame(place); }
  }

  // ---- sleep when idle
  function wake() {
    setState("sleeping", false);
    clearTimeout(idleTimer);
    idleTimer = setTimeout(function () {
      if (!root.classList.contains("is-listening")) setState("sleeping", true);
    }, IDLE_MS);
  }

  // ---- one-shot animations (loop on click, celebration at the end)
  function play(state, ms) {
    if (busy) return;
    busy = true;
    setState(state, true);
    setTimeout(function () { setState(state, false); busy = false; }, reduced ? 600 : ms);
  }

  body.addEventListener("click", function () { wake(); play("blasting", 1300); });

  if (end && "IntersectionObserver" in window) {
    new IntersectionObserver(function (entries, obs) {
      if (entries[0].isIntersecting && !celebrated) {
        celebrated = true;
        obs.disconnect();
        setTimeout(function () { play("celebrating", 2200); }, 300);
      }
    }, { threshold: 0.4 }).observe(end);
  }

  // ---- headphones while any audio on the page plays (media events don't bubble)
  document.addEventListener("play", function (e) {
    if (e.target.tagName === "AUDIO") { setState("listening", true); wake(); }
  }, true);
  ["pause", "ended"].forEach(function (type) {
    document.addEventListener(type, function (e) {
      if (e.target.tagName === "AUDIO") setState("listening", false);
    }, true);
  });

  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener("resize", onScroll);
  ["mousemove", "keydown", "touchstart"].forEach(function (t) {
    window.addEventListener(t, wake, { passive: true });
  });

  place();
  wake();
  space.hidden = false;
  // float in after the page has settled
  setTimeout(function () { space.classList.add("is-here"); }, reduced ? 0 : 250);
})();
