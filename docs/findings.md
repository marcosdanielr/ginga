# Findings — onde mora o bloqueio

Doc vivo. Registrar aqui tudo que a Fase 1 descobrir. O plugin (Fase 2) sai daqui.

## Pergunta central

O gate de câmera/tela no Brasil é:
- **(A) client-side** — flag/experiment que o cliente lê pra esconder os botões? → patch Vencord resolve.
- **(B) servidor de voz** — RTC recusa vídeo de região BR? → precisa spoof de região, patch não basta.

Sintoma conhecido: VPN uma vez → destrava o servidor → persiste após desconectar.
Isso aponta forte pra **(A)** com estado cacheado, ou região de voz do canal pinada.

## Candidatos a investigar

- `/api/v9/experiments` — assignment de experiment por região. Suspeito nº 1.
- GET do guild — campo `features` ou região.
- GET do channel de voz — `rtc_region`.
- Gateway `READY` — `experiments`, `geo_ordered_rtc_regions`, flags de usuário.

## Método

1. Capturar SEM vpn (`tools/capture.py`, `GINGA_OUT=capturas/sem-vpn`).
2. Capturar COM vpn (`GINGA_OUT=capturas/com-vpn`).
3. `python tools/diff.py`.
4. Colar o diff relevante abaixo.

## Resultado — ACHADO (rota DevTools, sem VPN)

Gate = **experiment client-side** `2026-08-video-guard`.

Módulo Webpack **625075**:
```js
a=(0,i.mj)({
  name:"2026-08-video-guard",
  kind:"user",
  defaultConfig:{videoEnabled:!0},
  variations:{1:{videoEnabled:!1},2:{videoEnabled:!1}}
})
```
Export `k` = objeto do experiment com `.getConfig({location}) -> {videoEnabled}`.
BR cai em variação 1/2 → `videoEnabled:false`.

Consumidores de `getConfig(...).videoEnabled`:
- 222692 `handleCameraUnavailable` (modal)
- 702904 `handleScreenshareUnavailable` (modal)
- 300128 `VideoGuardBannerManager`
- 177141 notice `VIDEO_UNSUPPORTED_BROWSER`
- 453028 MediaEngineStore `tc(e)=getConfig(e).videoEnabled`

O botão em si (tooltip "Camera Unavailable") vem de 151476:
```js
cameraUnavailable = firstVideoDevice.disabled || !supports(O5.VIDEO)
```

CONFIRMADO ao vivo (BR, sem VPN):
```
getConfig().videoEnabled = false
supports(VIDEO)          = false
video device "default"   = { disabled: true }
```
Os 3 descem do mesmo experiment (não é hardware — câmera funciona com VPN).
O MediaEngine lê o guard na INICIALIZAÇÃO → override em runtime chega tarde.
Patch tem que agir no LOAD do módulo. Vencord faz exatamente isso.

- Tipo de gate (A/B): **A (client-side)**
- Patch: módulo 625075, `videoEnabled:!1` -> `videoEnabled:!0` (as 2 variações).
  Implementado em `plugin/index.tsx`.
