#!/usr/bin/env bash
#
# Ginga - instalador (Linux). Desbloqueia camera/tela do Discord (guard regional BR).
# Self-contained: o plugin vai embutido aqui embaixo. Mande so este arquivo.
#
# Uso:   bash install-ginga.sh
# Requer: git, node, pnpm.
#
# Idempotente: rodar de novo atualiza o Vencord, rebuilda e re-injeta.
# Rode de novo sempre que o Discord atualizar e o Ginga parar de funcionar.

set -euo pipefail

GINGA_DIR="${GINGA_DIR:-$HOME/.ginga}"
VENCORD_DIR="$GINGA_DIR/Vencord"

echo "== Ginga installer =="

# 1. dependencias
missing=0
for c in git node pnpm; do
    if ! command -v "$c" >/dev/null 2>&1; then
        echo "  FALTA: $c"
        missing=1
    fi
done
if [ "$missing" = 1 ]; then
    echo
    echo "Instala o que faltou e roda de novo."
    echo "  node/pnpm: https://nodejs.org  +  'corepack enable' (ou npm i -g pnpm)"
    exit 1
fi

mkdir -p "$GINGA_DIR"

# 2. clona ou atualiza o Vencord
if [ -d "$VENCORD_DIR/.git" ]; then
    echo "-- atualizando Vencord"
    git -C "$VENCORD_DIR" pull --ff-only
else
    echo "-- clonando Vencord"
    git clone --depth 1 https://github.com/Vendicated/Vencord "$VENCORD_DIR"
fi

# 3. escreve o plugin Ginga (fonte embutida abaixo)
echo "-- instalando plugin Ginga"
mkdir -p "$VENCORD_DIR/src/userplugins/ginga"
cat > "$VENCORD_DIR/src/userplugins/ginga/index.tsx" <<'GINGA_PLUGIN_EOF'
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
GINGA_PLUGIN_EOF

# 4. build
echo "-- build (pode demorar na 1a vez)"
cd "$VENCORD_DIR"
pnpm install --frozen-lockfile || pnpm install
rm -rf dist
pnpm build

# 5. inject
echo
echo "-- injetando no Discord"
echo "   Na tela do injetor: escolhe teu Discord (stable) e clica em INJECT."
pnpm inject

echo
echo "== OK =="
echo "1. Fecha o Discord completo:  pkill -f Discord"
echo "2. Reabre o Discord."
echo "3. Settings -> Vencord -> Plugins -> ativa 'Ginga'."
echo "4. Reinicia o Discord de novo."
echo "5. Entra numa call -> camera/tela liberadas."
