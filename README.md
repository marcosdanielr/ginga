# Ginga

Unblocks Discord camera and screen share in Brazil, directly in the client.

The regional block is a **client-side Discord experiment** (`2026-08-video-guard`):
users in Brazil are bucketed into a variation with `videoEnabled:false`, which disables
video **send and receive**. Ginga is a [Vencord](https://vencord.dev) plugin that forces
that flag back to `true` at module load.

> **Both sides** of a call need Ginga — the sender and the receiver. The guard blocks
> video in both directions, so without the patch the other side won't see your video.

> ⚠️ Client mods violate Discord's Terms of Service. Account action is possible (rare).
> Everyone using it should know this first.

## Install — one binary (recommended)

Download the `ginga` executable for your OS (from the repo's Releases / CI artifacts)
and run it. It patches the official Discord client. No Node, git, or pnpm needed.

```
ginga                # inject
ginga uninstall      # remove
```

Then: restart Discord, enable **Ginga** in `Settings > Vencord > Plugins`, restart again.
Run it again if a Discord update ever breaks the patch.

Source and build details: [`injector/`](injector/).

## Install — from source (alternative)

Requires `git`, `node`, `pnpm`. Clones Vencord, embeds the plugin, builds, and injects.

```bash
bash install-ginga.sh                                   # Linux/macOS
powershell -ExecutionPolicy Bypass -File install-ginga.ps1   # Windows
```

## Layout

```
injector/            single-binary injector (Rust); bundles the official Vencord CLI + our dist
plugin/index.tsx     the Vencord plugin (canonical patch source)
install-ginga.sh     from-source installer (Linux/macOS)
install-ginga.ps1    from-source installer (Windows)
tools/build-dist.sh  regenerate the dist embedded in the injector
tools/webpack-search.js  re-find the flag if Discord rotates it
docs/findings.md     analysis of how the block works
.github/workflows/   CI: builds Linux + Windows binaries
```

## Planned

Custom **Vesktop** build (a standalone client with Ginga baked in) as a second
distribution option. Not implemented yet.

## Maintenance — if the patch stops working

Discord may rename the experiment. To re-find the flag: open DevTools, paste
`tools/webpack-search.js` in the console, and follow `tools/README.md` /
`docs/findings.md`. Update `plugin/index.tsx`, run `tools/build-dist.sh`, rebuild.
