#!/usr/bin/env bash
#
# Regenerate injector/assets/dist from the Ginga plugin.
# Run this after editing plugin/index.tsx (or when Discord rotates the flag),
# then rebuild the injector so the new patch ships in the binary.
#
# Requires: git, node, pnpm.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${GINGA_WORK:-$HOME/.cache/ginga-build}"
VENCORD="$WORK/Vencord"

mkdir -p "$WORK"

if [ -d "$VENCORD/.git" ]; then
    git -C "$VENCORD" pull --ff-only
else
    git clone --depth 1 https://github.com/Vendicated/Vencord "$VENCORD"
fi

mkdir -p "$VENCORD/src/userplugins/ginga"
cp "$ROOT/plugin/index.tsx" "$VENCORD/src/userplugins/ginga/index.tsx"

cd "$VENCORD"
pnpm install --frozen-lockfile || pnpm install
rm -rf dist
pnpm build

DST="$ROOT/injector/assets/dist"
rm -rf "$DST"
mkdir -p "$DST"
cp dist/*.js dist/*.css dist/package.json "$DST"/

echo
echo "dist regenerated at injector/assets/dist:"
ls "$DST"
echo
echo "Now rebuild the injector: cargo build --release --manifest-path injector/Cargo.toml"
