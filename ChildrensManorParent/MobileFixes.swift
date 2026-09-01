import Foundation

enum MobileFixes {
    /// Injected on every portal page. Restyles the desktop layout for a phone
    /// without posting credentials anywhere except the school's own origin.
    static let javaScript = #"""
(function () {
  if (window.__cmmsMobileFixes) return;
  window.__cmmsMobileFixes = true;

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

    /* Sidr hamburger drawer, if the portal enables it */
    .sidr { max-width: 86vw !important; }

    /* Keep payment / calendar widgets usable */
    iframe, .webcam_iframe, .iframe1 {
      max-width: 100% !important;
      width: 100% !important;
    }
  `;

  var style = document.createElement("style");
  style.id = "cmms-mobile-fixes";
  style.type = "text/css";
  style.appendChild(document.createTextNode(css));
  (document.head || document.documentElement).appendChild(style);

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
  ensureViewport();

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

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", enlargeTaps);
  } else {
    enlargeTaps();
  }
})();
"""#
}
