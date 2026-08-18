# tools/ — maintenance

## build-dist.sh

Regenerate the dist embedded in the injector after editing `plugin/index.tsx` (or
after re-finding the flag). Requires `git`, `node`, `pnpm`.

```bash
tools/build-dist.sh
cargo build --release --manifest-path injector/Cargo.toml
```

## webpack-search.js

Find the check that blocks camera/screen share in Discord's Webpack modules. Use it
when Discord changes something and the patch stops working (e.g. the
`2026-08-video-guard` experiment gets renamed).

1. Open Discord with Vencord (or Vesktop) and DevTools (`Ctrl+Shift+I`).
2. Paste all of `webpack-search.js` into the console → prints `[ginga] ready`.
3. Locate the logic:
   ```js
   gingaPeek("Camera Unavailable")       // tooltip string -> i18n table
   gingaGrep("video-guard").map(h => h.id) // the guard experiment
   gingaPeek("videoEnabled", 400)         // flag consumers
   ```
4. Confirm the gate live:
   ```js
   gingaWreq(<id>).k.getConfig({ location: "test" })   // {videoEnabled:false} in BR
   ```
5. Update `find`/`match` in `plugin/index.tsx`, regenerate the dist
   (`build-dist.sh`), and record it in `docs/findings.md`.
