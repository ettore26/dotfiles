-- Post-process kulala's "Copy as cURL" output into a shell-friendly command.
--
-- kulala builds the curl string inside the kulala-core binary (see
-- lua/kulala/cmd/kulala_core_bridge.lua -> action "to_curl"), so there is no
-- upstream option to change its shape. The only local lever is rewriting the
-- string after kulala puts it on the clipboard:
--
--   * query string -> `-G` + one `--data-urlencode` per param (percent-decoded)
--   * one flag per line with `\` continuations
--   * drop flags that are noise when pasting into a terminal
--
-- Query splitting is skipped when the request has a body (-d/-F/-T) or a
-- non-GET method, since `--data-urlencode` would move the params into the body.
local M = {}

-- Flags removed from the copied command.
-- `-v/-s` only affect curl's own output; `--globoff` and `--http1.1` DO change
-- behaviour on the wire -- delete an entry here to keep it.
M.drop_flags = { "-v", "--verbose", "-s", "--silent", "-g", "--globoff", "--http1.1" }

-- Flags removed together with their argument.
M.drop_flags_with_value = { "-A", "--user-agent" }

-- Drop headers whose value is empty (kulala emits `-H "Content-Type;:"`).
M.drop_empty_headers = true

local function set(list)
  local t = {}
  for _, v in ipairs(list) do
    t[v] = true
  end
  return t
end

-- curl flags that consume the next argv entry
local takes_value = set({
  "-H", "--header", "-X", "--request", "--url",
  "-d", "--data", "--data-raw", "--data-binary", "--data-urlencode", "--json",
  "-F", "--form", "-T", "--upload-file",
  "-A", "--user-agent", "-u", "--user", "-b", "--cookie", "-c", "--cookie-jar",
  "-e", "--referer", "-o", "--output", "-D", "--dump-header", "-w", "--write-out",
  "-x", "--proxy", "-E", "--cert", "--key", "--cacert", "--resolve", "--interface",
  "-m", "--max-time", "--connect-timeout", "--retry", "--limit-rate", "--range", "-r",
})

local body_flags = set({
  "-d", "--data", "--data-raw", "--data-binary", "--data-urlencode", "--json",
  "-F", "--form", "-T", "--upload-file",
})

---Split a shell command line into argv, honouring '...', "..." and \ escapes.
---@param cmd string
---@return string[]
local function tokenize(cmd)
  local tokens, buf, i, n = {}, nil, 1, #cmd

  while i <= n do
    local c = cmd:sub(i, i)

    if c:match("%s") then
      if buf then
        tokens[#tokens + 1], buf = buf, nil
      end
      i = i + 1
    elseif c == "'" then
      local j = cmd:find("'", i + 1, true) or n + 1
      buf = (buf or "") .. cmd:sub(i + 1, j - 1)
      i = j + 1
    elseif c == '"' then
      local out, j = {}, i + 1
      while j <= n do
        local ch = cmd:sub(j, j)
        if ch == "\\" and cmd:sub(j + 1, j + 1):match('["\\%$`]') then
          out[#out + 1], j = cmd:sub(j + 1, j + 1), j + 2
        elseif ch == '"' then
          break
        else
          out[#out + 1], j = ch, j + 1
        end
      end
      buf = (buf or "") .. table.concat(out)
      i = j + 1
    elseif c == "\\" then
      -- `\<newline>` is a line continuation, anything else is an escaped char
      if cmd:sub(i + 1, i + 1) ~= "\n" then buf = (buf or "") .. cmd:sub(i + 1, i + 1) end
      i = i + 2
    else
      buf = (buf or "") .. c
      i = i + 1
    end
  end

  if buf then tokens[#tokens + 1] = buf end
  return tokens
end

---Quote for sh: double quotes when safe, else single quotes with '\'' escaping.
---@param s string
local function shq(s)
  if not s:find('[\'"\\%$`]') then return '"' .. s .. '"' end
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

---URLs and plain words get a shape of their own: URLs are always single-quoted
---so `?`/`&`/`$` survive any shell, bare words (methods) need no quotes at all.
local function shq_url(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function shq_word(s)
  return s:match("^[%w%._%-/]+$") and s or shq(s)
end

local function url_decode(s)
  s = s:gsub("+", " ")
  return (s:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

---@param query string everything after `?`
---@return string[] pairs of decoded `key=value`
local function decode_params(query)
  local params = {}
  for pair in query:gmatch("[^&]+") do
    local key, value = pair:match("^([^=]*)=(.*)$")
    params[#params + 1] = key and (url_decode(key) .. "=" .. url_decode(value)) or url_decode(pair)
  end
  return params
end

---Rewrite a one-line curl command into the multi-line `-G` form.
---Returns the input unchanged if it is not a curl command.
---@param cmd string
---@return string
function M.prettify(cmd)
  local tokens = tokenize(cmd)
  if (tokens[1] or ""):gsub(".*/", "") ~= "curl" then return cmd end

  local drop, drop_with_value = set(M.drop_flags), set(M.drop_flags_with_value)
  local headers, data, others = {}, {}, {}
  local url, method, has_body, get_flag

  local i = 2
  while i <= #tokens do
    local token, value = tokens[i], nil

    -- `-Hfoo` / `-XPOST`: split the value off the short flag
    if #token > 2 and token:match("^%-[^%-]") and takes_value[token:sub(1, 2)] then
      token, value = token:sub(1, 2), token:sub(3)
    elseif takes_value[token] then
      value, i = tokens[i + 1], i + 1
    end

    if drop[token] or drop_with_value[token] then
      -- skipped
    elseif token == "-G" or token == "--get" then
      get_flag = true
    elseif token == "-H" or token == "--header" then
      headers[#headers + 1] = value
    elseif token == "-X" or token == "--request" then
      method = value
    elseif body_flags[token] then
      has_body = true
      data[#data + 1] = { token, value }
    elseif token == "--url" then
      url = value
    elseif token:sub(1, 1) == "-" then
      others[#others + 1] = { token, value }
    else
      url = url or token
    end

    i = i + 1
  end

  if not url then return cmd end

  local base, query = url:match("^([^?]*)%?(.*)$")
  local split_query = query and query ~= "" and not has_body and (not method or method == "GET")

  local lines = { "curl " .. ((split_query or get_flag) and "-G " or "") .. shq_url(split_query and base or url) }
  local function add(line)
    lines[#lines + 1] = line
  end

  -- `-G` already implies GET, so an explicit `-X GET` is dropped there
  if method and not (split_query and method == "GET") then add("-X " .. shq_word(method)) end

  for _, flag in ipairs(others) do
    add(flag[1] .. (flag[2] and " " .. shq(flag[2]) or ""))
  end

  for _, header in ipairs(headers) do
    local name, value = header:match("^([^:]*):(.*)$")
    if not (M.drop_empty_headers and name and name ~= "" and vim.trim(value) == "") then
      add("-H " .. shq(header))
    end
  end

  if split_query then
    for _, param in ipairs(decode_params(query)) do
      add("--data-urlencode " .. shq(param))
    end
  end

  for _, flag in ipairs(data) do
    add(flag[1] .. (flag[2] and " " .. shq(flag[2]) or ""))
  end

  return table.concat(lines, " \\\n  ")
end

---Wrap `require("kulala").copy()` so every entry point gets the rewrite: the
---`<leader>Rc` keymap, the "Copy as cURL" LSP code action (which resolves
---`Kulala.copy` at call time) and `:lua require("kulala").copy()`.
---Safe to call more than once.
function M.patch_copy()
  if M._patched then return end
  M._patched = true

  local kulala = require("kulala")
  local copy = kulala.copy

  kulala.copy = function(...)
    copy(...)

    -- kulala leaves the register untouched when it fails to build the command,
    -- so this can be a stale value -- prettify() is a no-op on anything that is
    -- not a curl command, and idempotent on one it already rewrote.
    local curl = vim.fn.getreg("+")
    if curl:match("^%s*curl%s") then vim.fn.setreg("+", M.prettify(curl)) end
  end
end

return M
