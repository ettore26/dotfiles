-- Custom foldexpr for http/rest files.
--
-- vim.treesitter.foldexpr() does not process injected language trees
-- (see TODO in nvim/runtime/lua/vim/treesitter/_fold.lua). This means
-- JSON/XML bodies inside kulala_http never get fold boundaries from
-- the injected json parser.
--
-- Strategy:
--   level 1 – treesitter (section) @fold handles ### separators
--   level 2+ – pattern-match JSON { [ openers and } ] closers by indent depth
local M = {}

function M.foldexpr()
  local lnum = vim.v.lnum
  local ts_fold = vim.treesitter.foldexpr()

  -- Treesitter owns section-level boundaries (### lines)
  if type(ts_fold) == "string" and (ts_fold:sub(1, 1) == ">" or ts_fold:sub(1, 1) == "<") then
    return ts_fold
  end

  -- Only apply JSON pattern folding to indented lines.
  -- Headers, request line, and outer { } at indent 0 stay at section level.
  local indent = vim.fn.indent(lnum)
  if indent > 0 then
    local sw = math.max(vim.fn.shiftwidth(), 1)
    local level = math.floor(indent / sw) + 1
    local line = vim.fn.getline(lnum)

    if line:match("[{%[]%s*$") then   -- line opens an object or array
      return ">" .. level
    end
    if line:match("^%s*[}%]]") then   -- line closes an object or array
      return "<" .. level
    end

    return level
  end

  return ts_fold
end

return M
