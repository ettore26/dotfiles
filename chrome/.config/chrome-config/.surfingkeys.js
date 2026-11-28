// ── Ctrl+[ as Esc, like Vim ──
api.map('<Ctrl-[>', '<Esc>');    // normal mode (closes popups, hints, the help screen)
api.imap('<Ctrl-[>', '<Esc>');   // insert mode (leave the text field)
api.vmap('<Ctrl-[>', '<Esc>');   // visual / caret mode
api.cmap('<Ctrl-[>', '<Esc>');   // omnibar (the T / t / : popups)

// Open new tabs right after the current one
settings.newTabPosition = 'right';

// ── Theme ──
settings.theme = `
.sk_theme {
    font-family: Input Sans Condensed, Charcoal, sans-serif;
    font-size: 10pt;
    background: #24272e;
    color: #abb2bf;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #d0d0d0;
}
.sk_theme .url {
    color: #61afef;
}
.sk_theme .annotation {
    color: #56b6c2;
}
.sk_theme .omnibar_highlight {
    color: #528bff;
}
.sk_theme .omnibar_timestamp {
    color: #e5c07b;
}
.sk_theme .omnibar_visitcount {
    color: #98c379;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #303030;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #3e4452;
}
#sk_status, #sk_find {
    font-size: 20pt;
}`;
