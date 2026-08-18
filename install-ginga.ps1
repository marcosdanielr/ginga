# Ginga - instalador (Windows). Desbloqueia camera/tela do Discord (guard regional BR).
# Self-contained: o plugin vai embutido aqui. Mande so este arquivo.
#
# Uso (PowerShell):
#   powershell -ExecutionPolicy Bypass -File install-ginga.ps1
# Requer: git, node, pnpm.
#
# Idempotente: rodar de novo atualiza o Vencord, rebuilda e re-injeta.
# Rode de novo sempre que o Discord atualizar e o Ginga parar de funcionar.

$ErrorActionPreference = "Stop"

$GingaDir   = if ($env:GINGA_DIR) { $env:GINGA_DIR } else { Join-Path $HOME ".ginga" }
$VencordDir = Join-Path $GingaDir "Vencord"

Write-Host "== Ginga installer =="

# 1. dependencias
$missing = $false
foreach ($c in @("git", "node", "pnpm")) {
    if (-not (Get-Command $c -ErrorAction SilentlyContinue)) {
        Write-Host "  FALTA: $c"
        $missing = $true
    }
}
if ($missing) {
    Write-Host ""
    Write-Host "Instala o que faltou e roda de novo."
    Write-Host "  node/pnpm: https://nodejs.org  +  'corepack enable' (ou npm i -g pnpm)"
    exit 1
}

New-Item -ItemType Directory -Force -Path $GingaDir | Out-Null

# 2. clona ou atualiza o Vencord
if (Test-Path (Join-Path $VencordDir ".git")) {
    Write-Host "-- atualizando Vencord"
    git -C $VencordDir pull --ff-only
} else {
    Write-Host "-- clonando Vencord"
    git clone --depth 1 https://github.com/Vendicated/Vencord $VencordDir
}

# 3. escreve o plugin Ginga (fonte embutida abaixo)
Write-Host "-- instalando plugin Ginga"
$pluginDir = Join-Path $VencordDir "src\userplugins\ginga"
New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null

$plugin = @'
import definePlugin from "@utils/types";

export default definePlugin({
    name: "Ginga",
    description: "Desbloqueia camera e compartilhamento de tela (neutraliza o video-guard regional BR).",
    authors: [{ name: "marcosdanielr", id: 0n }],

    patches: [
        {
            // modulo que define o experiment "2026-08-video-guard".
            find: '"2026-08-video-guard"',
            replacement: {
                // as variacoes forcam videoEnabled:!1 (false). Vira !0 (true).
                match: /videoEnabled:!1/g,
                replace: "videoEnabled:!0",
            },
        },
    ],
});
'@
Set-Content -Path (Join-Path $pluginDir "index.tsx") -Value $plugin -Encoding UTF8

# 4. build
Write-Host "-- build (pode demorar na 1a vez)"
Set-Location $VencordDir
try { pnpm install --frozen-lockfile } catch { pnpm install }
if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
pnpm build

# 5. inject
Write-Host ""
Write-Host "-- injetando no Discord"
Write-Host "   Na tela do injetor: escolhe teu Discord (stable) e clica em INJECT."
pnpm inject

Write-Host ""
Write-Host "== OK =="
Write-Host "1. Fecha o Discord completo (inclusive a bandeja/tray)."
Write-Host "2. Reabre o Discord."
Write-Host "3. Settings -> Vencord -> Plugins -> ativa 'Ginga'."
Write-Host "4. Reinicia o Discord de novo."
Write-Host "5. Entra numa call -> camera/tela liberadas."
