---Import-management helpers, mostly for ts_ls / gopls / jdtls.
---
---For ts_ls we prefer the typed code-action kinds shipped by the server
---(`source.organizeImports.ts`, `source.removeUnused.ts`,
---`source.addMissingImports.ts`) and only fall back to the raw command
---name as a safety net.
local M = {}

---Apply the first code action whose kind matches one of `kinds`.
local function apply_code_action(kinds)
  vim.lsp.buf.code_action({
    apply  = true,
    filter = function(action)
      if not action.kind then return false end
      for _, k in ipairs(kinds) do
        if action.kind == k or action.kind:match('^' .. vim.pesc(k)) then
          return true
        end
      end
      return false
    end,
  })
end

---Return the first attached LSP client whose name matches one of `names`.
local function find_client(names)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    for _, n in ipairs(names) do
      if client.name == n then return client end
    end
  end
  return nil
end

function M.organize_imports()
  if find_client({ 'ts_ls', 'tsserver', 'typescript-tools' }) then
    apply_code_action({ 'source.organizeImports.ts', 'source.organizeImports' })
    return
  end
  if find_client({ 'gopls' }) then
    apply_code_action({ 'source.organizeImports' })
    return
  end
  if find_client({ 'jdtls' }) then
    apply_code_action({ 'source.organizeImports' })
    return
  end
  apply_code_action({ 'source.organizeImports' })
end

function M.add_missing_imports()
  if find_client({ 'ts_ls', 'tsserver', 'typescript-tools' }) then
    apply_code_action({ 'source.addMissingImports.ts', 'source.addMissingImports', 'quickfix' })
    return
  end
  apply_code_action({ 'source.addMissingImports', 'quickfix' })
end

function M.remove_unused_imports()
  if find_client({ 'ts_ls', 'tsserver', 'typescript-tools' }) then
    apply_code_action({ 'source.removeUnused.ts', 'source.removeUnused' })
    return
  end
  apply_code_action({ 'source.removeUnused' })
end

---Run add-missing -> remove-unused -> organize, with small delays so each
---batch of edits settles before the next request goes out.
function M.fix_all_imports()
  M.add_missing_imports()
  vim.defer_fn(function()
    M.remove_unused_imports()
    vim.defer_fn(M.organize_imports, 100)
  end, 100)
end

function M.setup_keybindings(bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set('n', '<leader>oi', M.organize_imports,
    vim.tbl_extend('force', opts, { desc = 'Organize / Fix Imports' }))
  vim.keymap.set('n', '<leader>ia', M.add_missing_imports,
    vim.tbl_extend('force', opts, { desc = 'Add Missing Imports' }))
  vim.keymap.set('n', '<leader>ir', M.remove_unused_imports,
    vim.tbl_extend('force', opts, { desc = 'Remove Unused Imports' }))
  vim.keymap.set('n', '<leader>if', M.fix_all_imports,
    vim.tbl_extend('force', opts, { desc = 'Fix All Import Issues' }))
end

---Backwards-compatible alias; older config called this `fix_imports`.
M.fix_imports = M.organize_imports

return M
