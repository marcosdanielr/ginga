# Ginga

Desbloqueia câmera e compartilhamento de tela do Discord no Brasil, direto no cliente.

O bloqueio regional é um **experiment client-side** do Discord (`2026-08-video-guard`):
usuários no BR caem numa variação com `videoEnabled:false`, o que desabilita envio
**e** recebimento de vídeo. O Ginga é um plugin [Vencord](https://vencord.dev) que,
no carregamento, força esse flag de volta pra `true`.

> Os **dois lados** de uma call precisam do Ginga: quem envia e quem recebe. O guard
> trava vídeo nas duas direções — sem o patch, o outro lado não vê seu vídeo.

> ⚠️ Client mods violam os Termos de Serviço do Discord. Risco de ação na conta
> existe (raro). Cada usuário deve saber disso antes de usar.

## Instalação (script)

Requer `git`, `node` e `pnpm`. O script clona o Vencord, embute o plugin, builda e
injeta no seu Discord oficial.

**Linux/macOS:**
```bash
bash install-ginga.sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File install-ginga.ps1
```

Depois: abra o Discord → `Settings → Vencord → Plugins` → ative **Ginga** → reinicie.

Rode o script de novo sempre que um update do Discord quebrar o patch (ele atualiza,
rebuilda e re-injeta).

## Estrutura

```
plugin/index.tsx     # o plugin Vencord (fonte canônica do patch)
install-ginga.sh     # instalador Linux/macOS (plugin embutido)
install-ginga.ps1    # instalador Windows (plugin embutido)
tools/               # webpack-search.js: re-achar a flag se o Discord rotacionar
docs/findings.md     # análise de onde/como o bloqueio funciona
```

> Os instaladores **embutem** uma cópia de `plugin/index.tsx`. Ao editar o patch,
> atualize os dois (a fonte e o trecho embutido nos scripts).

## Distribuição alternativa (futuro)

Empacotar o Ginga num **Vesktop custom** (1 binário, sem `git`/`node` na máquina do
colega). Ainda não implementado — por hora só a rota script.

## Manutenção — se o patch parar de funcionar

O Discord pode renomear o experiment. Pra re-achar a flag: abra o DevTools, cole
`tools/webpack-search.js` no console e siga `tools/README.md` / `docs/findings.md`.
