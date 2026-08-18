/*
 * Ginga - desbloqueia camera e compartilhamento de tela no Discord (bloqueio BR).
 *
 * Gate identificado (Fase 1, via DevTools): experiment client-side
 *   "2026-08-video-guard" (modulo Webpack 625075).
 *   defaultConfig {videoEnabled:true}, mas variacoes 1/2 {videoEnabled:false}.
 *   Usuario BR cai na variacao 1/2 -> videoEnabled:false -> camera/tela travadas.
 *   Cascata: getConfig().videoEnabled=false faz supports(VIDEO)=false e
 *   video device .disabled=true no MediaEngine.
 *
 * Patch: no LOAD do modulo 625075, forcar as variacoes pra videoEnabled:true.
 *   Tem que ser no load (nao em runtime) porque o MediaEngine le o guard na
 *   inicializacao. Um patch Vencord roda exatamente nesse ponto.
 *
 * Ver docs/findings.md pra a analise completa.
 */

import definePlugin from "@utils/types";

export default definePlugin({
    name: "Ginga",
    description: "Desbloqueia camera e compartilhamento de tela (neutraliza o video-guard regional BR).",
    authors: [{ name: "marcosdanielr", id: 0n }],

    patches: [
        {
            // modulo 625075: define o experiment "2026-08-video-guard".
            find: '"2026-08-video-guard"',
            replacement: {
                // as duas variacoes forcam videoEnabled:!1 (false). Vira !0 (true).
                // escopo = so este modulo (find acima), entao flag global e seguro:
                // as unicas ocorrencias de videoEnabled:!1 aqui sao as variacoes.
                match: /videoEnabled:!1/g,
                replace: "videoEnabled:!0",
            },
        },
    ],
});
