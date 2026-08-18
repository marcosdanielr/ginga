# tools/ — manutenção

## webpack-search.js

Acha a checagem que bloqueia câmera/tela nos módulos Webpack do Discord. Use quando
o Discord mudar algo e o patch do Ginga parar de funcionar (ex.: renomearam o
experiment `2026-08-video-guard`).

Passos:
1. Abra o Discord com Vencord (ou o Vesktop) e o DevTools (`Ctrl+Shift+I`).
2. Cole todo o conteúdo de `webpack-search.js` no console → imprime `[ginga] pronto`.
3. Busque a lógica:
   ```js
   gingaPeek("Camera Unavailable")     // string do tooltip -> tabela i18n
   gingaGrep("video-guard").map(h=>h.id) // o experiment do guard
   gingaPeek("videoEnabled", 400)       // consumidores do flag
   ```
4. Confirme o gate ao vivo:
   ```js
   gingaWreq(<id>).k.getConfig({location:"test"})   // {videoEnabled:false} no BR
   ```
5. Atualize o `find`/`match` em `plugin/index.tsx` (e a cópia embutida nos scripts)
   e registre em `docs/findings.md`.
