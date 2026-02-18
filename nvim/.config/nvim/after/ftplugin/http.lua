vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.require('config.http_fold').foldexpr()"
