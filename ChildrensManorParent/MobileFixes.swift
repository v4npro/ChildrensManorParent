import Foundation

enum MobileFixes {
    /// Injected on every portal page. Restyles the desktop layout for a phone
    /// without posting credentials anywhere except the school's own origin.
    static let javaScript = #"""
(function () {
  var css = `
    html { -webkit-text-size-adjust: 100%; }
    body, html { min-width: 0 !important; max-width: 100% !important; overflow-x: hidden !important; }
    img { max-width: 100% !important; height: auto !important; }

    input, select, textarea, button {
      font-size: 16px !important;
      max-width: 100% !important;
    }
    input.form-control, select.form-control, textarea.form-control {
      height: auto !important;
      min-height: 44px !important;
      padding: 10px 12px !important;
      border-radius: 10px !important;
    }
    button, .btn, a.btn, .btn1, .btn2, .btn3 {
      min-height: 44px !important;
      border-radius: 10px !important;
    }

    /* ---- Login / forgot passcode ---- */
    form#frmtlogin, form#forgotPasswordForm, form.form1, form.margin0 {
      height: auto !important; min-height: 100% !important;
    }
    #wrapper { float: none !important; width: 100% !important; }
    .container.bg-parent, .container.bg-staff, .bg-parent, .bg-staff {
      display: block !important;
      height: auto !important;
      min-height: 100vh !important;
      width: 100% !important;
      background-size: cover !important;
      background-position: center !important;
      padding: 0 !important;
      margin: 0 !important;
      align-items: stretch !important;
    }
    .bg-signin {
      float: none !important;
      width: 100% !important;
      max-width: 100% !important;
      margin: 0 !important;
      min-height: 100vh !important;
      height: auto !important;
      padding: calc(18px + env(safe-area-inset-top, 0px)) 20px calc(28px + env(safe-area-inset-bottom, 0px)) !important;
      box-sizing: border-box !important;
      box-shadow: none !important;
    }
    .bg-signin .logo { margin-bottom: 28px !important; float: none !important; }
    .bg-signin .logo img { height: 72px !important; width: auto !important; }
    .bg-signin h1, h1.parent_login, h1.forget {
      font-size: 22px !important;
      margin-bottom: 22px !important;
      color: #fff !important;
    }
    .bg-signin label { font-size: 15px !important; }
    .bg-signin .form-group { margin-bottom: 14px !important; }
    .bg-signin .btn1 {
      width: 100% !important;
      padding: 12px 16px !important;
      font-size: 18px !important;
      margin-top: 8px !important;
    }
    .bg-signin .a1, .bg-signin a { color: #fff !important; }

    /* ---- Logged-in chrome ---- */
    .header { padding-top: env(safe-area-inset-top, 0px) !important; }
    .header-right {
      float: none !important;
      width: 100% !important;
      max-width: 100% !important;
      text-align: left !important;
      padding: 8px 12px !important;
    }
    .logo-small { border: none !important; margin: 0 0 8px 0 !important; padding: 0 !important; display: block !important; }
    .txt-logo-right { border-top: none !important; margin-top: 0 !important; padding-top: 0 !important; }

    /* Slide the left icon rail into a bottom bar on phones */
    .bg-lnb {
      position: fixed !important;
      left: 0 !important;
      right: 0 !important;
      top: auto !important;
      bottom: 0 !important;
      width: 100% !important;
      height: auto !important;
      min-height: 0 !important;
      z-index: 4000 !important;
      overflow: auto !important;
      padding-bottom: env(safe-area-inset-bottom, 0px) !important;
      box-shadow: 0 -2px 10px rgba(0,0,0,0.18) !important;
    }
    .lnb, .bg-lnb ul, .bg-lnb .lnb {
      display: flex !important;
      flex-direction: row !important;
      width: 100% !important;
      margin: 0 !important;
      padding: 4px 0 6px !important;
      list-style: none !important;
    }
    .lnb li, .bg-lnb li {
      flex: 1 1 0 !important;
      float: none !important;
      width: auto !important;
      text-align: center !important;
    }
    .lnb li a, .bg-lnb li a {
      display: flex !important;
      flex-direction: column !important;
      align-items: center !important;
      justify-content: center !important;
      min-height: 52px !important;
      padding: 6px 4px !important;
      font-size: 10px !important;
      color: #fff !important;
      text-decoration: none !important;
    }
    .wrap-pad {
      padding: 12px 12px calc(88px + env(safe-area-inset-bottom, 0px)) !important;
      width: 100% !important;
      box-sizing: border-box !important;
    }

    .whitebox, .whitebox1, .whitebox2 {
      min-height: 0 !important;
      overflow-x: auto !important;
      -webkit-overflow-scrolling: touch;
    }
    table { width: 100% !important; max-width: 100% !important; }
    .table5-div, .table2-div, .table4-div, .student-reg-tabel-in {
      overflow-x: auto !important;
      -webkit-overflow-scrolling: touch;
    }

    .modal-dialog, .modal-dialog1, .modal-content {
      width: auto !important;
      max-width: 96% !important;
      margin: 12px auto !important;
    }

    .breadcrumb { font-size: 13px !important; }
    .topbar { padding-left: 8px !important; padding-right: 8px !important; }

    .sidr { max-width: 86vw !important; }

    iframe, .webcam_iframe, .iframe1 {
      max-width: 100% !important;
      width: 100% !important;
    }

    /* Logged-in: kill the full-bleed watermark so it cannot sit across the black + blue bands */
    body.cmms-logged-in #background_cycler,
    body.cmms-logged-in #background_cycler img {
      display: none !important;
      visibility: hidden !important;
    }
    body.cmms-logged-in,
    body.cmms-logged-in .bg-parent,
    body.cmms-logged-in .bg-staff,
    body.cmms-logged-in .bg-homepage,
    body.cmms-logged-in .bg-parent-poral,
    body.cmms-logged-in .bg-gray,
    body.cmms-logged-in .header,
    body.cmms-logged-in .wrap-pad {
      background-image: none !important;
    }

    .cmms-dup-user {
      display: none !important;
      height: 0 !important;
      min-height: 0 !important;
      margin: 0 !important;
      padding: 0 !important;
      overflow: hidden !important;
      border: 0 !important;
    }
    body.cmms-logged-in .header {
      padding-top: 0 !important;
      min-height: 0 !important;
    }

    .cmms-student-banner {
      background: #005bab !important;
      background-image: none !important;
      color: #fff !important;
      position: relative !important;
      z-index: 4 !important;
      padding: 16px 16px 20px !important;
      overflow: hidden !important;
    }
    .cmms-student-banner, .cmms-student-banner * {
      background-image: none !important;
    }
  `;

  var style = document.getElementById("cmms-mobile-fixes");
  if (!style) {
    style = document.createElement("style");
    style.id = "cmms-mobile-fixes";
    style.type = "text/css";
    (document.head || document.documentElement).appendChild(style);
  }
  style.textContent = css;

  function isLoginPage() {
    return !!document.getElementById("frmtlogin") || /\/login\/?$/i.test(location.pathname);
  }

  function ensureViewport() {
    var meta = document.querySelector('meta[name="viewport"]');
    if (!meta) {
      meta = document.createElement("meta");
      meta.name = "viewport";
      (document.head || document.documentElement).appendChild(meta);
    }
    meta.setAttribute(
      "content",
      "width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover"
    );
  }

  function enlargeTaps() {
    var nodes = document.querySelectorAll("a, button, input[type=submit], .btn");
    for (var i = 0; i < nodes.length; i++) {
      var el = nodes[i];
      if (el.getBoundingClientRect().height < 32) {
        el.style.minHeight = "44px";
        el.style.display = el.style.display || "inline-flex";
        el.style.alignItems = "center";
      }
    }
  }

  function menuWrap(el) {
    return el.closest(".user_right, .header-right, .user-con, .user-box, .dd1") || el;
  }

  function hideDuplicateUserMenus() {
    var nodes = document.querySelectorAll(".user-con, .dd1, .user-box");
    var groups = {};
    for (var i = 0; i < nodes.length; i++) {
      var el = nodes[i];
      if (el.closest(".cmms-dup-user")) continue;
      var text = (el.innerText || "").replace(/\s+/g, " ").trim();
      if (!text) continue;
      var key = text.slice(0, 48);
      if (!groups[key]) groups[key] = [];
      groups[key].push({
        el: el,
        top: el.getBoundingClientRect().top
      });
    }
    Object.keys(groups).forEach(function (key) {
      var list = groups[key];
      if (list.length < 2) return;
      list.sort(function (a, b) { return a.top - b.top; });
      var keep = list[list.length - 1];
      for (var i = 0; i < list.length - 1; i++) {
        var wrap = menuWrap(list[i].el);
        wrap.classList.add("cmms-dup-user");
      }
      var keepWrap = menuWrap(keep.el);
      keepWrap.classList.remove("cmms-dup-user");
      keepWrap.style.removeProperty("display");
    });

    var headers = document.querySelectorAll(".header, .header-right");
    for (var h = 0; h < headers.length; h++) {
      var header = headers[h];
      if (!header.querySelector(".cmms-dup-user")) continue;
      var leftover = header.querySelector(".user-con:not(.cmms-dup-user), .dd1:not(.cmms-dup-user), .user-box:not(.cmms-dup-user)");
      if (!leftover) header.classList.add("cmms-dup-user");
    }
  }

  function stripBannerBackground() {
    if (isLoginPage()) {
      document.body.classList.remove("cmms-logged-in");
      return;
    }
    document.body.classList.add("cmms-logged-in");

    var cycler = document.getElementById("background_cycler");
    if (cycler) cycler.style.display = "none";

    var headings = document.querySelectorAll("h1, h2, h3, h4, h5, div, span, p, label, strong");
    for (var i = 0; i < headings.length; i++) {
      var t = (headings[i].textContent || "").replace(/\s+/g, " ").trim();
      if (t === "Student Details") {
        var node = headings[i];
        for (var k = 0; k < 8 && node; k++) {
          node.classList.add("cmms-student-banner");
          node.style.backgroundImage = "none";
          node = node.parentElement;
          if (node && (node.classList.contains("wrap-pad") || node.id === "wrapper" || node === document.body)) break;
        }
        break;
      }
    }

    var imgs = document.querySelectorAll("img");
    for (var j = 0; j < imgs.length; j++) {
      var img = imgs[j];
      if (img.closest(".user-con, .user-box, .user-pic, .imgbox1, .cmms-user-bar, .bg-signin")) continue;
      var src = (img.getAttribute("src") || "").toLowerCase();
      var rect = img.getBoundingClientRect();
      var isLogo = /logo|combined|cmms|home_bg|bg-home|cycler/.test(src);
      var sitsOnBanner = rect.top < 260 && rect.height > 70 && rect.width > 80;
      if (isLogo && sitsOnBanner) {
        img.style.display = "none";
      }
    }
  }

  function hookLoginForm() {
    var form = document.getElementById("frmtlogin");
    if (!form || form.getAttribute("data-cmms-hooked")) return;
    form.setAttribute("data-cmms-hooked", "1");
    form.addEventListener("submit", function () {
      var user = document.getElementById("username");
      var pass = document.getElementById("password");
      if (!user || !pass) return;
      try {
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.cmmsAuth) {
          window.webkit.messageHandlers.cmmsAuth.postMessage({
            type: "save",
            username: user.value || "",
            password: pass.value || ""
          });
        }
      } catch (e) {}
    });
  }

  function run() {
    ensureViewport();
    hideDuplicateUserMenus();
    stripBannerBackground();
    enlargeTaps();
    hookLoginForm();
  }

  run();
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  }
  if (!window.__cmmsMobileObserver) {
    window.__cmmsMobileObserver = new MutationObserver(function () {
      if (window.__cmmsMobileTimer) return;
      window.__cmmsMobileTimer = setTimeout(function () {
        window.__cmmsMobileTimer = null;
        run();
      }, 80);
    });
    window.__cmmsMobileObserver.observe(document.documentElement, { childList: true, subtree: true });
  }
})();
"""#

    static let fillLoginJavaScript = #"""
(function (u, p) {
  var user = document.getElementById("username");
  var pass = document.getElementById("password");
  var form = document.getElementById("frmtlogin");
  if (!user || !pass || !form) return false;
  user.value = u;
  pass.value = p;
  if (window.jQuery) {
    window.jQuery(user).trigger("input").trigger("change");
    window.jQuery(pass).trigger("input").trigger("change");
  }
  form.submit();
  return true;
})
"""#
}
