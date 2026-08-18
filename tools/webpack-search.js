// Ginga - Fase 1 (rota DevTools, sem VPN).
// Cola no console do DevTools do Vesktop/Discord. Procura a checagem de regiao
// que esconde camera/tela.
//
// Se o DevTools bloquear paste: digita  allow pasting  e Enter, depois cola.

(function () {
    // Acha o require do Webpack por 2 caminhos (Vencord ou chunk global).
    let wreq;
    try { wreq = Vencord?.Webpack?.wreq; } catch (e) { /* ignore */ }

    if (!wreq || !wreq.m) {
        const chunk = window.webpackChunkdiscord_app;
        if (chunk) {
            chunk.push([[Symbol("ginga")], {}, r => { wreq = r; }]);
        }
    }

    if (!wreq || !wreq.m) {
        console.error("[ginga] nao achei o webpack require. Roda:  typeof Vencord, typeof window.webpackChunkdiscord_app");
        return;
    }

    // grep no source de TODOS os modulos. Retorna [{id, src}].
    function grep(pattern) {
        const re = new RegExp(pattern, "i");
        const hits = [];
        for (const id in wreq.m) {
            let src;
            try { src = wreq.m[id].toString(); } catch (e) { continue; }
            if (re.test(src)) hits.push({ id, src });
        }
        return hits;
    }

    // mostra so um trecho em volta do match.
    function peek(pattern, ctx = 200) {
        const re = new RegExp(pattern, "i");
        const hits = grep(pattern);
        console.log(`[ginga] ${hits.length} modulo(s) batem "${pattern}"`);
        for (const { id, src } of hits) {
            const m = src.match(re);
            const i = m ? m.index : 0;
            console.log(`\n--- modulo ${id} ---`);
            console.log(src.slice(Math.max(0, i - ctx), i + ctx));
        }
    }

    window.gingaGrep = grep;
    window.gingaPeek = peek;
    window.gingaWreq = wreq;
    console.log(`[ginga] pronto. ${Object.keys(wreq.m).length} modulos. use gingaPeek("Camera Unavailable")`);
})();
