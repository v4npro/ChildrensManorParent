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

    /* ---- Logged-in dashboard (from manor.txt) ---- */
    body.cmms-logged-in {
      background: #eef2f6 !important;
      background-image: none !important;
    }
    body.cmms-logged-in #background_cycler,
    body.cmms-logged-in #background_cycler img {
      display: none !important;
    }
    body.cmms-logged-in .profile_image.profile_mob,
    body.cmms-logged-in .profile_mob,
    body.cmms-logged-in nav.nav_cls .navbar-header,
    body.cmms-logged-in nav.nav_cls .navbar-brand,
    body.cmms-logged-in .left_side_cls {
      display: none !important;
      height: 0 !important;
      margin: 0 !important;
      padding: 0 !important;
      overflow: hidden !important;
    }
    body.cmms-logged-in nav.nav_cls,
    body.cmms-logged-in nav.nav_cls.navbar-inverse,
    body.cmms-logged-in .respons_nav {
      display: block !important;
      background: #005bab !important;
      background-image: none !important;
      border: 0 !important;
      margin: 0 !important;
      min-height: 0 !important;
      box-shadow: none !important;
    }
    body.cmms-logged-in nav.nav_cls .navbar-collapse,
    body.cmms-logged-in #myNavbar {
      display: block !important;
      height: auto !important;
      padding: 16px 16px 18px !important;
      background: #005bab !important;
      overflow: visible !important;
    }
    body.cmms-logged-in nav.nav_cls h5 {
      color: #fff !important;
      font-size: 12px !important;
      letter-spacing: 0.06em !important;
      text-transform: uppercase !important;
      margin: 0 0 8px !important;
      padding: 0 !important;
    }
    body.cmms-logged-in nav.nav_cls .nav-pills {
      margin: 0 !important;
    }
    body.cmms-logged-in nav.nav_cls .nav-pills > li {
      float: none !important;
      width: 100% !important;
    }
    body.cmms-logged-in nav.nav_cls .nav-pills > li > a {
      color: #fff !important;
      background: transparent !important;
      padding: 8px 0 !important;
      font-size: 16px !important;
      line-height: 1.35 !important;
    }
    body.cmms-logged-in nav.nav_cls .nav-pills label {
      display: inline-block !important;
      min-width: 102px !important;
      opacity: 0.85 !important;
      font-weight: 600 !important;
      margin: 0 8px 0 0 !important;
    }
    body.cmms-logged-in nav.nav_cls hr {
      border-color: rgba(255,255,255,0.25) !important;
      margin: 12px 0 !important;
    }
    body.cmms-logged-in nav.nav_cls .in_out {
      margin: 8px 0 0 !important;
    }
    body.cmms-logged-in nav.nav_cls .in_out a,
    body.cmms-logged-in nav.nav_cls .in_out button,
    body.cmms-logged-in nav.nav_cls .in_out .btn {
      display: block !important;
      width: 100% !important;
      max-width: 100% !important;
      border: 0 !important;
      border-radius: 12px !important;
      min-height: 48px !important;
      font-size: 17px !important;
      font-weight: 600 !important;
    }
    body.cmms-logged-in .cmms-code-row {
      display: flex !important;
      flex-wrap: wrap !important;
      align-items: center !important;
      gap: 8px !important;
      padding: 10px 28px 8px 0 !important;
      color: #fff !important;
      list-style: none !important;
    }
    body.cmms-logged-in .cmms-code-row .cmms-code-label {
      min-width: 0 !important;
      width: 100% !important;
      font-weight: 600 !important;
      opacity: 0.9 !important;
      font-size: 13px !important;
      letter-spacing: 0.02em !important;
    }
    body.cmms-logged-in .cmms-code-row input {
      flex: 1 1 140px !important;
      min-height: 44px !important;
      border: 0 !important;
      border-radius: 10px !important;
      padding: 8px 12px !important;
      font-size: 16px !important;
      color: #111 !important;
      background: #fff !important;
    }
    body.cmms-logged-in .cmms-code-row .cmms-code-value {
      flex: 1 1 auto !important;
      font-size: 16px !important;
    }
    body.cmms-logged-in .cmms-code-row button {
      min-height: 44px !important;
      padding: 0 16px !important;
      margin-right: 12px !important;
      border: 0 !important;
      border-radius: 10px !important;
      background: #fff !important;
      color: #005bab !important;
      font-weight: 700 !important;
      font-size: 15px !important;
    }
    body.cmms-checkin nav.nav_cls {
      display: block !important;
    }
    body.cmms-checkin nav.nav_cls .in_out,
    body.cmms-checkin nav.nav_cls hr,
    body.cmms-checkin .profile_desk,
    body.cmms-checkin .profile_mob,
    body.cmms-checkin .navbar-brand,
    body.cmms-checkin .left_side_cls,
    body.cmms-checkin .right_side_cls,
    body.cmms-checkin .parent_contact {
      display: none !important;
    }
    body.cmms-checkin #cmms-parent-name {
      display: block !important;
      text-align: left !important;
      color: #fff !important;
      font-size: 18px !important;
      font-weight: 700 !important;
      padding: 2px 0 10px !important;
    }
    body.cmms-checkin .cmms-chk-btn.cmms-chk-circle {
      background: #fff !important;
      color: #005bab !important;
      border: 3px solid #005bab !important;
      box-sizing: border-box !important;
    }
    body.cmms-checkin .cmms-chk-btn.cmms-chk-circle.is-on {
      background: #4da23e !important;
      border-color: #4da23e !important;
      color: #fff !important;
    }
    body.cmms-checkin .cmms-chk-btn.cmms-chk-circle.is-absent {
      background: #c7332c !important;
      border-color: #c7332c !important;
      color: #fff !important;
    }
    body.cmms-logged-in .student_detail,
    body.cmms-logged-in .row.content,
    body.cmms-logged-in .mid_section,
    body.cmms-logged-in .mid_section.col-12,
    body.cmms-logged-in .mid_section.col-sm-8 {
      width: 100% !important;
      max-width: 100% !important;
      float: none !important;
      margin: 0 !important;
      padding-left: 0 !important;
      padding-right: 0 !important;
      left: auto !important;
    }
    body.cmms-logged-in .mid_section {
      padding: 8px 12px 24px !important;
      background: #fff !important;
    }
    body.cmms-logged-in .profile_desk {
      display: flex !important;
      align-items: center !important;
      justify-content: flex-start !important;
      gap: 10px !important;
      padding: 4px 4px 12px !important;
      margin: 0 !important;
      background: #fff !important;
      float: none !important;
      width: auto !important;
    }
    body.cmms-logged-in .profile_desk .avatar {
      width: 40px !important;
      height: 40px !important;
      border-radius: 50% !important;
      object-fit: cover !important;
    }
    body.cmms-logged-in .profile_desk p {
      margin: 0 !important;
      font-size: 16px !important;
      font-weight: 600 !important;
      color: #005bab !important;
    }
    body.cmms-logged-in nav.tab_cls,
    body.cmms-logged-in .tab_cls {
      margin: 0 0 8px !important;
      overflow: hidden !important;
    }
    body.cmms-logged-in nav.tab_cls .nav.nav-tabs.nav-fill,
    body.cmms-logged-in .tab_cls > .nav.nav-tabs,
    body.cmms-logged-in .tab_cls .nav-tabs {
      display: flex !important;
      flex-direction: row !important;
      flex-wrap: nowrap !important;
      align-items: stretch !important;
      overflow-x: auto !important;
      overflow-y: hidden !important;
      -webkit-overflow-scrolling: touch;
      width: 100% !important;
      min-width: 0 !important;
      border: none !important;
    }
    body.cmms-logged-in .tab_cls > div a.nav-item.nav-link,
    body.cmms-logged-in .tab_cls a.nav-item.nav-link,
    body.cmms-logged-in .tab_cls .nav-link {
      display: flex !important;
      flex-direction: column !important;
      align-items: center !important;
      justify-content: center !important;
      flex: 0 0 auto !important;
      float: none !important;
      width: auto !important;
      max-width: none !important;
      min-width: 64px !important;
      margin: 0 !important;
      margin-bottom: 0 !important;
      text-align: center !important;
      font-size: 11px !important;
      line-height: 1.15 !important;
      padding: 8px 10px 10px !important;
      white-space: nowrap !important;
    }
    body.cmms-logged-in .tab_cls > div a.nav-item.nav-link img,
    body.cmms-logged-in .tab_cls .nav-link img {
      display: block !important;
      margin: 0 auto 4px !important;
      margin-right: 0 !important;
      width: 22px !important;
      height: 22px !important;
      flex-shrink: 0 !important;
    }
    body.cmms-logged-in .tab_cls > div a.nav-item.nav-link > span {
      display: block !important;
      white-space: nowrap !important;
    }
    body.cmms-logged-in .tab_cls > div a.nav-item.nav-link.active:after {
      display: none !important;
    }

    body.cmms-logged-in #no-more-tables input[type="checkbox"] {
      position: absolute !important;
      opacity: 0 !important;
      width: 1px !important;
      height: 1px !important;
      pointer-events: none !important;
    }
    body.cmms-logged-in #no-more-tables td:has(.cmms-chk-btn) {
      padding-left: 12px !important;
      padding-right: 12px !important;
    }
    body.cmms-logged-in #no-more-tables td:has(.cmms-chk-btn):before {
      display: none !important;
    }
    body.cmms-logged-in .cmms-chk-btn {
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      width: 100% !important;
      min-height: 52px !important;
      margin: 6px 0 !important;
      padding: 10px 14px !important;
      border: 0 !important;
      border-radius: 12px !important;
      background: #e8eef4 !important;
      color: #005bab !important;
      font-size: 17px !important;
      font-weight: 700 !important;
    }
    body.cmms-logged-in .cmms-chk-row {
      display: flex !important;
      flex-direction: row !important;
      justify-content: space-evenly !important;
      align-items: center !important;
      gap: 16px !important;
      padding: 10px 8px 14px !important;
      width: 100% !important;
    }
    body.cmms-logged-in .cmms-chk-btn.cmms-chk-circle {
      width: 92px !important;
      height: 92px !important;
      min-width: 92px !important;
      min-height: 92px !important;
      max-width: 92px !important;
      margin: 0 !important;
      padding: 0 !important;
      border-radius: 50% !important;
      flex: 0 0 92px !important;
      font-size: 16px !important;
      line-height: 1.1 !important;
      text-align: center !important;
    }
    body.cmms-checkin #no-more-tables td.cmms-chk-wrap {
      display: block !important;
      padding: 12px 8px !important;
      border: 0 !important;
      width: 100% !important;
    }
    body.cmms-checkin #no-more-tables td.cmms-chk-wrap:before {
      display: none !important;
    }
    body.cmms-logged-in #no-more-tables td.cmms-chk-cell-hide {
      display: none !important;
      height: 0 !important;
      padding: 0 !important;
      margin: 0 !important;
      border: 0 !important;
    }
    body.cmms-logged-in #no-more-tables img.avatar,
    body.cmms-logged-in #no-more-tables img[src*="default_thumb"],
    body.cmms-logged-in #no-more-tables img[src*="thumb"],
    body.cmms-logged-in #no-more-tables img[alt*="Profile"],
    body.cmms-logged-in #no-more-tables img[alt*="Student"],
    body.cmms-logged-in #no-more-tables td:has(.cmms-chk-row) > img,
    body.cmms-logged-in #no-more-tables td:has(.cmms-chk-row) img,
    body.cmms-logged-in .cmms-roster-photo-hide {
      display: none !important;
      width: 0 !important;
      height: 0 !important;
      margin: 0 !important;
      padding: 0 !important;
    }
    body.cmms-logged-in .cmms-chk-btn.is-on {
      background: #4da23e !important;
      color: #fff !important;
    }
    body.cmms-logged-in .cmms-chk-btn.is-absent {
      background: #c7332c !important;
      color: #fff !important;
    }
    body.cmms-logged-in .breadcrumb a {
      display: inline-flex !important;
      align-items: center !important;
      min-height: 44px !important;
      padding: 0 14px !important;
      border-radius: 10px !important;
      background: #005bab !important;
      color: #fff !important;
    }
    body.cmms-logged-in .tab-content,
    body.cmms-logged-in #nav-tabContent,
    body.cmms-logged-in .tab-pane {
      padding-left: 0 !important;
      padding-right: 0 !important;
    }
    body.cmms-logged-in .table-box,
    body.cmms-logged-in .table-box1 {
      overflow-x: auto !important;
      -webkit-overflow-scrolling: touch;
    }
    body.cmms-logged-in #calendar .fc-view > table {
      width: 100% !important;
    }
    body.cmms-logged-in .right_side_cls {
      display: block !important;
      width: 100% !important;
      float: none !important;
      background: #f4f7fa !important;
      color: #222 !important;
      padding: 16px !important;
      margin: 0 !important;
    }
    body.cmms-logged-in .right_side_cls a,
    body.cmms-logged-in .right_side_cls label {
      color: #222 !important;
    }
    body.cmms-logged-in .right_side_cls h5 {
      color: #005bab !important;
      font-size: 14px !important;
      text-transform: uppercase !important;
      letter-spacing: 0.04em !important;
    }

    /* ---- Older portal chrome ---- */
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
    /* Header/parent switcher above Student Details (.dd1 is white-on-dark). */
    body.cmms-logged-in .dd1,
    body.cmms-logged-in .header .user-box,
    body.cmms-logged-in .header .dropdown,
    body.cmms-logged-in .header-right .dropdown {
      display: none !important;
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

  function studentNameFromPage() {
    var items = document.querySelectorAll(".nav_cls .nav-pills li, .left_side_cls .nav-pills li");
    for (var i = 0; i < items.length; i++) {
      var t = (items[i].innerText || "").replace(/\s+/g, " ").trim();
      var m = t.match(/^Name:\s*(.+)$/i);
      if (m) return m[1].trim();
    }
    return "";
  }

  function postNative(payload) {
    try {
      if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.cmmsAuth) {
        window.webkit.messageHandlers.cmmsAuth.postMessage(payload);
      }
    } catch (e) {}
  }

  function renderCodeRow(row, editing) {
    var code = window.__cmmsClassroomCode || "";
    row.innerHTML = "";
    var label = document.createElement("span");
    label.className = "cmms-code-label";
    label.textContent = "Code reminder";
    row.appendChild(label);
    if (!editing && code) {
      var value = document.createElement("span");
      value.className = "cmms-code-value";
      value.textContent = code;
      row.appendChild(value);
      var edit = document.createElement("button");
      edit.type = "button";
      edit.textContent = "Edit";
      edit.addEventListener("click", function (ev) {
        ev.preventDefault();
        ev.stopPropagation();
        renderCodeRow(row, true);
      });
      row.appendChild(edit);
      return;
    }
    var input = document.createElement("input");
    input.type = "text";
    input.autocomplete = "off";
    input.autocapitalize = "characters";
    input.placeholder = "Enter code";
    input.value = code;
    input.setAttribute("aria-label", "Code reminder");
    row.appendChild(input);
    var save = document.createElement("button");
    save.type = "button";
    save.textContent = "Save";
    save.addEventListener("click", function (ev) {
      ev.preventDefault();
      ev.stopPropagation();
      var next = (input.value || "").replace(/^\s+|\s+$/g, "");
      window.__cmmsClassroomCode = next;
      postNative({ type: "codeSave", value: next, student: studentNameFromPage() });
      renderCodeRow(row, false);
    });
    row.appendChild(save);
    input.addEventListener("keydown", function (ev) {
      if (ev.key === "Enter") save.click();
    });
  }

  function ensureCodeRow() {
    if (isLoginPage()) return;
    var lists = document.querySelectorAll(".nav_cls .nav-pills");
    for (var i = 0; i < lists.length; i++) {
      var ul = lists[i];
      if (ul.querySelector(".cmms-code-row")) continue;
      var classroom = null;
      var items = ul.querySelectorAll("li");
      for (var j = 0; j < items.length; j++) {
        if (/Classroom:/i.test(items[j].textContent || "")) classroom = items[j];
      }
      if (!classroom) continue;
      var li = document.createElement("li");
      li.className = "cmms-code-row";
      classroom.parentNode.insertBefore(li, classroom.nextSibling);
      renderCodeRow(li, !(window.__cmmsClassroomCode));
    }
  }

  window.__cmmsApplySimpleMode = function (on) {
    window.__cmmsSimpleCheckIn = !!on;
    if (!document.body) return;
    if (on && /signin_out/i.test(location.pathname)) document.body.classList.add("cmms-checkin");
    else document.body.classList.remove("cmms-checkin");
  };

  window.__cmmsApplyClassroomCode = function (code) {
    window.__cmmsClassroomCode = code || "";
    var rows = document.querySelectorAll(".cmms-code-row");
    for (var i = 0; i < rows.length; i++) {
      renderCodeRow(rows[i], !window.__cmmsClassroomCode);
    }
    if (!rows.length) ensureCodeRow();
  };

  function forceHorizontalTabs() {
    var bar = document.querySelector(".tab_cls .nav-tabs");
    if (!bar) return;
    bar.style.setProperty("display", "flex", "important");
    bar.style.setProperty("flex-direction", "row", "important");
    bar.style.setProperty("flex-wrap", "nowrap", "important");
    bar.style.setProperty("overflow-x", "auto", "important");
    var links = bar.querySelectorAll("a.nav-item, a.nav-link");
    for (var i = 0; i < links.length; i++) {
      links[i].style.setProperty("display", "flex", "important");
      links[i].style.setProperty("flex-direction", "column", "important");
      links[i].style.setProperty("flex", "0 0 auto", "important");
      links[i].style.setProperty("width", "auto", "important");
      links[i].style.setProperty("max-width", "none", "important");
      links[i].style.setProperty("margin-bottom", "0", "important");
    }
  }

  function shortenTabLabels() {
    var map = {
      "Latest Feed": "Feed",
      "Announcement/Notifications": "Alerts",
      "Student Work": "Work",
      "Newsletters": "News",
      "Other Documents": "Docs",
      "Messages": "Inbox",
      "Calendar": "Calendar"
    };
    var spans = document.querySelectorAll(".tab_cls .nav-link span");
    for (var i = 0; i < spans.length; i++) {
      var t = (spans[i].textContent || "").replace(/\s+/g, " ").trim();
      if (map[t]) spans[i].textContent = map[t];
    }
  }

  function hideTopUserDropdown() {
    var headerMenus = document.querySelectorAll(".profile_image.profile_mob, .profile_mob, nav.nav_cls .navbar-header");
    for (var p = 0; p < headerMenus.length; p++) {
      headerMenus[p].classList.add("cmms-dup-user");
    }
  }

  function stripBannerBackground() {
    if (isLoginPage()) {
      document.body.classList.remove("cmms-logged-in");
      document.body.classList.remove("cmms-checkin");
      return;
    }
    document.body.classList.add("cmms-logged-in");
    if (typeof window.__cmmsSimpleCheckIn === "undefined") window.__cmmsSimpleCheckIn = true;
    if (window.__cmmsSimpleCheckIn && /signin_out/i.test(location.pathname)) {
      document.body.classList.add("cmms-checkin");
    } else {
      document.body.classList.remove("cmms-checkin");
    }
    var cycler = document.getElementById("background_cycler");
    if (cycler) cycler.style.display = "none";
    placeParentName();
  }

  function placeParentName() {
    var existing = document.getElementById("cmms-parent-name");
    if (!document.body.classList.contains("cmms-checkin")) {
      if (existing) existing.style.display = "none";
      return;
    }
    var src = document.querySelector(".profile_desk #lbd p, .profile_mob #lbd p, .profile_desk p");
    var name = src ? (src.innerText || "").replace(/\s+/g, " ").replace(/[▼▾]/g, "").trim() : "";
    var host = document.querySelector("nav.nav_cls #myNavbar, nav.nav_cls .navbar-collapse");
    if (!host || !name) return;
    var el = existing;
    if (!el) {
      el = document.createElement("div");
      el.id = "cmms-parent-name";
      host.insertBefore(el, host.firstChild);
    }
    el.textContent = name;
    el.style.display = "block";
  }

  function checkboxKind(cb) {
    var raw = "";
    var onclick = cb.getAttribute("onclick") || cb.getAttribute("onchange") || "";
    var statusMatch = onclick.match(/addInOutAbs\s*\([^,]+,\s*['\"]([^'\"]+)['\"]/i);
    if (statusMatch) raw = statusMatch[1];
    if (!raw) {
      var td = cb.closest("td");
      raw = (td && td.getAttribute("data-title")) || cb.getAttribute("title") || cb.getAttribute("aria-label") || "";
      if (!raw && td && td.parentNode) {
        var idx = Array.prototype.indexOf.call(td.parentNode.children, td);
        var table = cb.closest("table");
        var ths = table ? table.querySelectorAll("thead th") : [];
        if (ths[idx]) raw = (ths[idx].innerText || "");
      }
    }
    raw = (raw || "").replace(/\s+/g, " ").trim();
    var u = raw.toUpperCase();
    if (u === "IN" || u === "I" || /^check\s*in$/i.test(raw)) return { kind: "in", label: "In" };
    if (u === "OUT" || u === "O" || /^check\s*out$/i.test(raw)) return { kind: "out", label: "Out" };
    if (u === "ABS" || u === "ABSENT" || u === "A" || /^abs/i.test(raw)) return { kind: "abs", label: "Abs" };
    if (raw) return { kind: "other", label: raw };
    var lab = cb.closest("label");
    if (lab) {
      var lt = (lab.innerText || "").replace(/\s+/g, " ").trim();
      if (lt) return { kind: "other", label: lt };
    }
    return { kind: "other", label: "Select" };
  }

  function syncChkButton(cb, btn) {
    var on = !!cb.checked;
    var absent = btn.classList.contains("cmms-chk-abs") || /abs/i.test(btn.textContent || "");
    btn.classList.toggle("is-on", on && !absent);
    btn.classList.toggle("is-absent", on && absent);
  }

  function headerTextForCell(td) {
    var title = td.getAttribute("data-title") || "";
    if (title) return title;
    var tr = td.parentNode;
    var table = td.closest("table");
    if (!tr || !table) return "";
    var idx = Array.prototype.indexOf.call(tr.children, td);
    var ths = table.querySelectorAll("thead th");
    if (ths[idx]) return ths[idx].innerText || "";
    return "";
  }

  function groupCircleButtons(root) {
    var rows = root.querySelectorAll("tr");
    for (var r = 0; r < rows.length; r++) {
      var tr = rows[r];
      if (tr.querySelector(".cmms-chk-row")) continue;
      var circles = tr.querySelectorAll(".cmms-chk-circle");
      if (!circles.length) continue;
      var tds = tr.querySelectorAll("td");
      for (var t = 0; t < tds.length; t++) {
        var label = (headerTextForCell(tds[t]) + " " + (tds[t].innerText || "")).replace(/\s+/g, " ").trim();
        var onlyPhoto = tds[t].querySelector("img") && !(tds[t].innerText || "").replace(/\s+/g, "").length;
        if (onlyPhoto || /allerg/i.test(label) || /\bname\b/i.test(label) || /^student\b/i.test(label)) {
          if (!tds[t].querySelector(".cmms-chk-circle, input[type=checkbox]")) {
            tds[t].classList.add("cmms-chk-cell-hide");
          }
        }
      }
      var imgs = tr.querySelectorAll("img, .avatar");
      for (var p = 0; p < imgs.length; p++) {
        imgs[p].classList.add("cmms-roster-photo-hide");
      }
      var holder = document.createElement("div");
      holder.className = "cmms-chk-row";
      var wrap = document.createElement("td");
      wrap.className = "cmms-chk-wrap";
      wrap.appendChild(holder);
      tr.insertBefore(wrap, tr.firstChild);
      for (var c = 0; c < circles.length; c++) {
        var cell = circles[c].closest("td");
        holder.appendChild(circles[c]);
        if (cell && cell !== wrap) cell.classList.add("cmms-chk-cell-hide");
      }
    }
    var heads = root.querySelectorAll("thead th");
    for (var h = 0; h < heads.length; h++) {
      var ht = (heads[h].innerText || "").replace(/\s+/g, " ").trim();
      if (/allerg/i.test(ht) || /\bname\b/i.test(ht) || /^student\b/i.test(ht)) {
        heads[h].classList.add("cmms-chk-cell-hide");
      }
    }
  }

  function buttonizeCheckboxes() {
    var root = document.getElementById("no-more-tables");
    if (!root) return;
    var boxes = root.querySelectorAll('input[type="checkbox"]');
    for (var i = 0; i < boxes.length; i++) {
      var cb = boxes[i];
      if (cb.getAttribute("data-cmms-btn")) continue;
      cb.setAttribute("data-cmms-btn", "1");
      var info = checkboxKind(cb);
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "cmms-chk-btn";
      if (info.kind === "in" || info.kind === "out" || info.kind === "abs") {
        btn.className += " cmms-chk-circle cmms-chk-" + info.kind;
      }
      btn.textContent = info.label;
      syncChkButton(cb, btn);
      (function (checkbox, button) {
        button.addEventListener("click", function (ev) {
          ev.preventDefault();
          ev.stopPropagation();
          checkbox.click();
          syncChkButton(checkbox, button);
        });
      })(cb, btn);
      var host = cb.parentNode || root;
      host.appendChild(btn);
    }
    groupCircleButtons(root);
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
    hideTopUserDropdown();
    stripBannerBackground();
    shortenTabLabels();
    forceHorizontalTabs();
    ensureCodeRow();
    buttonizeCheckboxes();
    enlargeTaps();
    hookLoginForm();
    if (!isLoginPage() && window.__cmmsClassroomCode === undefined) {
      window.__cmmsClassroomCode = "";
      postNative({ type: "codeLoad", student: studentNameFromPage() });
    }
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
