#!/usr/bin/env bash
#
# Ginga installer (Linux/macOS). Unblocks Discord camera/screen share (BR video-guard).
# Self-contained: the plugin is embedded below. Ship just this file.
#
# Usage:   bash install-ginga.sh
# Requires: git, node, pnpm.
#
# Idempotent: re-running updates Vencord, rebuilds and re-injects.
# Re-run whenever a Discord update breaks the patch.

set -euo pipefail

GINGA_DIR="${GINGA_DIR:-$HOME/.ginga}"
VENCORD_DIR="$GINGA_DIR/Vencord"

echo "== Ginga installer =="

missing=0
for c in git node pnpm; do
    if ! command -v "$c" >/dev/null 2>&1; then
        echo "  MISSING: $c"
        missing=1
    fi
done
if [ "$missing" = 1 ]; then
    echo
    echo "Install what's missing and re-run."
    echo "  node/pnpm: https://nodejs.org  +  'corepack enable' (or npm i -g pnpm)"
    exit 1
fi

mkdir -p "$GINGA_DIR"

if [ -d "$VENCORD_DIR/.git" ]; then
    echo "-- updating Vencord"
    git -C "$VENCORD_DIR" pull --ff-only
else
    echo "-- cloning Vencord"
    git clone --depth 1 https://github.com/Vendicated/Vencord "$VENCORD_DIR"
fi

echo "-- installing the Ginga plugin"
mkdir -p "$VENCORD_DIR/src/userplugins/ginga"
cat > "$VENCORD_DIR/src/userplugins/ginga/index.tsx" <<'GINGA_PLUGIN_EOF'
import definePlugin from "@utils/types";

export default definePlugin({
    name: "Ginga",
    description: "Unblock camera and screen share (neutralizes the BR regional video-guard).",
    authors: [{ name: "marcosdanielr", id: 0n }],

    patches: [
        {
            find: '"2026-08-video-guard"',
            replacement: {
                match: /videoEnabled:!1/g,
                replace: "videoEnabled:!0",
            },
        },
    ],
});
GINGA_PLUGIN_EOF

echo "-- building (first run may take a while)"
cd "$VENCORD_DIR"
pnpm install --frozen-lockfile || pnpm install
rm -rf dist
pnpm build

echo
echo "-- injecting into Discord"
echo "   In the installer: pick your Discord (stable) and click INJECT."
pnpm inject

echo
echo "== OK =="
echo "1. Fully quit Discord:  pkill -f Discord"
echo "2. Reopen Discord."
echo "3. Settings > Vencord > Plugins > enable 'Ginga'."
echo "4. Restart Discord once more."
echo "5. Join a voice call -> camera/screen share unlocked."
