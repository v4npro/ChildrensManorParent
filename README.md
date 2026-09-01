# Manor Parent

A mobile-friendly iPhone app for the [Children’s Manor parent portal](https://portal.childrensmanor.com/tp/pa/login).

The school site blocks embedding in other web pages (`X-Frame-Options: SAMEORIGIN`), so this is a native app: it opens the **official portal** in a full-screen WebView and injects CSS so login and inner pages fit a phone.

## What it does

- Opens `https://portal.childrensmanor.com/tp/pa/login` directly
- Lets you sign in on the school’s page (username + passcode never leave that site)
- Makes the 380px desktop login panel full-width
- Enlarges tap targets and stops iOS from zooming on form fields
- Moves the left icon rail into a bottom bar after login
- Pull-to-refresh, back, home, and reload in the app chrome

This app does **not** store your passcode in source, Keychain, or a custom backend. iOS may keep the school’s own session cookie in the app’s WebKit data store, the same way Safari keeps you logged in.

## Open on a Mac

This machine is Windows; you need Xcode on a Mac to install it on an iPhone.

1. Copy `ChildrensManorParent` to the Mac (or open this folder if it is already synced).
2. Open `ChildrensManorParent.xcodeproj` in Xcode 16+.
3. Select your iPhone as the run destination.
4. Sign with team `KWXYT3K2WN` (already set) and bundle id `com.v4apps.manorparent`.
5. Run.

## Why not a website wrapper?

The portal’s Content-Security-Policy and `X-Frame-Options` refuse to load inside an iframe on another origin. A home-screen bookmark of the live site also cannot inject the mobile CSS. A native WebView is the path that actually works.

## Tune after first login

The injected layout in `ChildrensManorParent/MobileFixes.swift` is based on the public login page plus the portal’s CSS classes (`bg-signin`, `bg-lnb`, `wrap-pad`, `whitebox`, …). After you use it on a real dashboard, tell me which screens still overflow (attendance, billing, messages, photos) and we can tighten those rules. Do **not** paste your passcode into chat to do that — screenshots of the awkward screens are enough.
