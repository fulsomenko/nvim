---:checkhealth jsvim
---
---Reports whether the JS/TS toolchain (node, eslint_d, prettierd,
---vscode-js-debug, ts_ls, etc.) is available, which LSP clients are
---attached to the current buffer, and whether they advertise inlay
---hint support.

local M = {}

local h = vim.health or require('health')
local ok    = h.ok    or h.report_ok
local warn  = h.warn  or h.report_warn
local error_ = h.error or h.report_error
local info  = h.info  or h.report_info
local start = h.start or h.report_start

local function check_exe(name, friendly)
  if vim.fn.executable(name) == 1 then
    ok(('%s found at %s'):format(friendly or name, vim.fn.exepath(name)))
    return true
  else
    warn(('%s not found on PATH'):format(friendly or name))
    return false
  end
end

function M.check()
  start('jsvim: runtime')
  check_exe('node',                'node')
  check_exe('npm',                 'npm')
  check_exe('npx',                 'npx')
  if vim.fn.executable('pnpm') == 1 then check_exe('pnpm', 'pnpm') end
  if vim.fn.executable('yarn') == 1 then check_exe('yarn', 'yarn') end
  if vim.fn.executable('bun')  == 1 then check_exe('bun',  'bun')  end
  check_exe('tsc',                 'tsc (TypeScript compiler)')

  start('jsvim: language servers')
  check_exe('typescript-language-server', 'ts_ls (TypeScript LSP)')
  check_exe('vscode-eslint-language-server', 'eslint LSP')
  check_exe('vscode-json-language-server',   'json LSP')
  check_exe('vscode-css-language-server',    'css LSP')
  check_exe('vscode-html-language-server',   'html LSP')
  check_exe('tailwindcss-language-server',   'tailwindcss LSP')
  check_exe('emmet-language-server',         'emmet LSP')
  check_exe('yaml-language-server',          'yaml LSP')

  start('jsvim: format / lint')
  check_exe('prettierd', 'prettierd')
  check_exe('prettier',  'prettier')
  check_exe('eslint_d',  'eslint_d')

  start('jsvim: debug adapter')
  local js_debug = nixCats and nixCats('js-debug-path')
  if js_debug and vim.fn.filereadable(js_debug) == 1 then
    ok(('vscode-js-debug at %s'):format(js_debug))
  elseif js_debug then
    error_(('js-debug-path set but not readable: %s'):format(js_debug))
  else
    warn('nixCats("js-debug-path") not set — DAP launch configs will not work')
  end

  start('jsvim: attached LSP clients (current buffer)')
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    info('No LSP clients attached to this buffer')
  else
    for _, c in ipairs(clients) do
      local caps = c.server_capabilities or {}
      local extras = {}
      if caps.inlayHintProvider     then table.insert(extras, 'inlayHints')     end
      if caps.codeActionProvider    then table.insert(extras, 'codeAction')     end
      if caps.documentFormattingProvider then table.insert(extras, 'format')    end
      if caps.renameProvider        then table.insert(extras, 'rename')         end
      ok(('%s [%s]'):format(c.name, table.concat(extras, ', ')))
    end
  end

  start('jsvim: nixCats categories')
  local cats = { 'js', 'general', 'lint', 'format', 'debug', 'ai', 'general.cmp', 'general.treesitter', 'general.telescope' }
  for _, cat in ipairs(cats) do
    if nixCats(cat) then ok(('category %s = true'):format(cat))
    else                  info(('category %s = false'):format(cat)) end
  end
end

return M
