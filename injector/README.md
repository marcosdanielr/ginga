# ginga-injector

Single self-contained binary that patches the official Discord client with Vencord
+ the Ginga plugin. No Node, git, pnpm, or manual steps on the target machine.

It embeds two things and drives them at runtime:
- `assets/cli/` — the official [Vencord Installer](https://github.com/Vencord/Installer)
  CLI (does the actual, cross-platform, maintained injection).
- `assets/dist/` — Vencord prebuilt with the Ginga plugin baked in.

On run it extracts both to the user data dir (`~/.local/share/ginga` /
`%LOCALAPPDATA%\ginga`) and runs the CLI with `VENCORD_USER_DATA_DIR` +
`VENCORD_DEV_INSTALL=1` so it injects *our* dist.

## Usage

```
ginga                # inject (branch: stable)
ginga ptb            # inject into the PTB branch (or: canary)
ginga uninstall      # remove
```

After injecting: restart Discord, enable **Ginga** in `Settings > Vencord > Plugins`,
restart once more.

## Build

```
cargo build --release --manifest-path injector/Cargo.toml
```

Windows binaries are produced by CI (`.github/workflows/build.yml`) since this repo's
dev machine is Linux-only.

## Updating the embedded plugin/dist

Edit `../plugin/index.tsx`, then regenerate the embedded dist and rebuild:

```
../tools/build-dist.sh
cargo build --release --manifest-path injector/Cargo.toml
```
