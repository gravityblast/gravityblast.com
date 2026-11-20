// Share button in the post header. Works without JS as a <details> menu;
// with JS it uses the system share sheet where available (phones, Safari),
// adds "Copy link", and closes the menu on outside click or Escape.
(function () {
  "use strict";

  document.querySelectorAll(".share-menu").forEach(function (menu) {
    var summary = menu.querySelector("summary");
    var copy = menu.querySelector(".share-copy");
    var data = { title: menu.getAttribute("data-title"), url: menu.getAttribute("data-url") };
    var touch = window.matchMedia("(pointer: coarse)").matches;

    // Phones: go straight to the native share sheet.
    summary.addEventListener("click", function (e) {
      if (touch && navigator.share) {
        e.preventDefault();
        navigator.share(data).catch(function () {});
      }
    });

    if (navigator.clipboard) {
      copy.hidden = false;
      copy.addEventListener("click", function () {
        navigator.clipboard.writeText(data.url).then(function () {
          var label = copy.querySelector("span");
          label.textContent = "Link copied";
          setTimeout(function () { label.textContent = "Copy link"; menu.open = false; }, 1200);
        });
      });
    }

    document.addEventListener("click", function (e) {
      if (menu.open && !menu.contains(e.target)) menu.open = false;
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && menu.open) { menu.open = false; summary.focus(); }
    });
  });
})();
