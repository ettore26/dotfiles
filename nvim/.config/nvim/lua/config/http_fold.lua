-- Custom foldexpr for http/rest files.
--
-- vim.treesitter.foldexpr() does not process injected language trees
-- (see TODO in nvim/runtime/lua/vim/treesitter/_fold.lua). This means
-- JSON/XML bodies inside kulala_http never get fold boundaries from
-- the injected json parser.
--
-- Strategy:
--   preamble – above the first ###, each blank-line-separated group of
--              comments/variables folds on its own
--   level 1 – treesitter (section) @fold handles ### separators
--   level 2 – runs of 2+ comment lines inside a request
--   level 2+ – pattern-match JSON { [ openers and } ] closers by indent depth
local M = {}

-- Line number of the first ### separator (or line count + 1), cached per
-- changedtick so foldexpr stays linear over the buffer.
local function first_separator(buf)
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local cache = vim.b[buf].http_fold_sep
  if cache and cache[1] == tick then
    return cache[2]
  end
  local sep = vim.api.nvim_buf_line_count(buf) + 1
  for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if line:match("^###") then
      sep = i
      break
    end
  end
  vim.b[buf].http_fold_sep = { tick, sep }
  return sep
end

local function blank(lnum)
  return vim.fn.getline(lnum):match("^%s*$") ~= nil
end

-- `#` or `//` comment, but not a `###` separator.
local function comment(lnum)
  local line = vim.fn.getline(lnum)
  return (line:match("^%s*#") or line:match("^%s*//")) and not line:match("^###")
end

-- Fold level for a preamble line: 1 inside a multi-line group, 0 otherwise.
local function preamble_fold(lnum, sep)
  if blank(lnum) then
    return 0
  end
  local starts = lnum == 1 or blank(lnum - 1)
  local ends = lnum + 1 >= sep or blank(lnum + 1)
  if starts and ends then
    return 0
  end
  return starts and ">1" or 1
end

-- True when lnum sits inside a `< {% %}` / `> {% %}` script block. JS braces
-- there would otherwise trip the JSON heuristic and split the (script) fold.
local function in_script(lnum)
  local ok, node = pcall(vim.treesitter.get_node, {
    pos = { lnum - 1, math.max(vim.fn.indent(lnum), 0) },
    lang = "kulala_http",
    ignore_injections = true,
  })
  while ok and node do
    if node:type() == "script" then
      return true
    end
    node = node:parent()
  end
  return false
end

function M.foldexpr()
  local lnum = vim.v.lnum
  local sep = first_separator(vim.api.nvim_get_current_buf())
  if lnum < sep then
    return preamble_fold(lnum, sep)
  end

  local ts_fold = vim.treesitter.foldexpr()

  -- Treesitter owns section-level boundaries (### lines) and script blocks
  if type(ts_fold) == "string" and (ts_fold:sub(1, 1) == ">" or ts_fold:sub(1, 1) == "<") then
    return ts_fold
  end
  if in_script(lnum) then
    return ts_fold
  end

  -- Comment runs inside a request fold one level below the section
  if comment(lnum) then
    local starts = not comment(lnum - 1)
    if starts and not comment(lnum + 1) then
      return ts_fold
    end
    return starts and ">2" or 2
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
