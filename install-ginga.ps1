# Ginga installer (Windows). Unblocks Discord camera/screen share (BR video-guard).
# Self-contained: the plugin is embedded here. Ship just this file.
#
# Usage (PowerShell):
#   powershell -ExecutionPolicy Bypass -File install-ginga.ps1
# Requires: git, node, pnpm.
#
# Idempotent: re-running updates Vencord, rebuilds and re-injects.
# Re-run whenever a Discord update breaks the patch.

$ErrorActionPreference = "Stop"

$GingaDir   = if ($env:GINGA_DIR) { $env:GINGA_DIR } else { Join-Path $HOME ".ginga" }
$VencordDir = Join-Path $GingaDir "Vencord"

Write-Host "== Ginga installer =="

$missing = $false
foreach ($c in @("git", "node", "pnpm")) {
    if (-not (Get-Command $c -ErrorAction SilentlyContinue)) {
        Write-Host "  MISSING: $c"
        $missing = $true
    }
}
if ($missing) {
    Write-Host ""
    Write-Host "Install what's missing and re-run."
    Write-Host "  node/pnpm: https://nodejs.org  +  'corepack enable' (or npm i -g pnpm)"
    exit 1
}

New-Item -ItemType Directory -Force -Path $GingaDir | Out-Null

if (Test-Path (Join-Path $VencordDir ".git")) {
    Write-Host "-- updating Vencord"
    git -C $VencordDir pull --ff-only
} else {
    Write-Host "-- cloning Vencord"
    git clone --depth 1 https://github.com/Vendicated/Vencord $VencordDir
}

Write-Host "-- installing the Ginga plugin"
$pluginDir = Join-Path $VencordDir "src\userplugins\ginga"
New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null

$plugin = @'
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
'@
Set-Content -Path (Join-Path $pluginDir "index.tsx") -Value $plugin -Encoding UTF8

Write-Host "-- building (first run may take a while)"
Set-Location $VencordDir
try { pnpm install --frozen-lockfile } catch { pnpm install }
if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
pnpm build

Write-Host ""
Write-Host "-- injecting into Discord"
Write-Host "   In the installer: pick your Discord (stable) and click INJECT."
pnpm inject

Write-Host ""
Write-Host "== OK =="
Write-Host "1. Fully quit Discord (including the tray icon)."
Write-Host "2. Reopen Discord."
Write-Host "3. Settings > Vencord > Plugins > enable 'Ginga'."
Write-Host "4. Restart Discord once more."
Write-Host "5. Join a voice call -> camera/screen share unlocked."
