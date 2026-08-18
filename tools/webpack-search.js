// Ginga - flag finder (DevTools route). Paste into the Vesktop/Discord DevTools
// console to locate the region check that hides camera/screen share.
//
// If DevTools blocks paste: type  allow pasting  and Enter, then paste.

(function () {
    let wreq;
    try { wreq = Vencord?.Webpack?.wreq; } catch (e) { /* ignore */ }

    if (!wreq || !wreq.m) {
        const chunk = window.webpackChunkdiscord_app;
        if (chunk) {
            chunk.push([[Symbol("ginga")], {}, r => { wreq = r; }]);
        }
    }

    if (!wreq || !wreq.m) {
        console.error("[ginga] webpack require not found. Try:  typeof Vencord, typeof window.webpackChunkdiscord_app");
        return;
    }

    // grep every module's source. Returns [{id, src}].
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

    // print just the slice around each match.
    function peek(pattern, ctx = 200) {
        const re = new RegExp(pattern, "i");
        const hits = grep(pattern);
        console.log(`[ginga] ${hits.length} module(s) match "${pattern}"`);
        for (const { id, src } of hits) {
            const m = src.match(re);
            const i = m ? m.index : 0;
            console.log(`\n--- module ${id} ---`);
            console.log(src.slice(Math.max(0, i - ctx), i + ctx));
        }
    }

    window.gingaGrep = grep;
    window.gingaPeek = peek;
    window.gingaWreq = wreq;
    console.log(`[ginga] ready. ${Object.keys(wreq.m).length} modules. try gingaPeek("Camera Unavailable")`);
})();
