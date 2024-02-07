------------------------------------------- GITSIGNS.NVIM ------------------------------------------

return {
  'lewis6991/gitsigns.nvim',
  opts = {
    attach_to_untracked = true,
    current_line_blame = true,
    current_line_blame_opts = { delay = 250 },
    current_line_blame_formatter = '    <author> (<author_time>) :: <summary>',
    current_line_blame_formatter_nc = '    [ not committed ]',

    on_attach = function(bufnr)
      local function nnoremap(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, { noremap = true, buffer = bufnr})
      end
      local gs = require 'gitsigns'
      nnoremap('<Leader>gl', gs.toggle_current_line_blame)
      nnoremap('<Leader>gp', gs.preview_hunk_inline)
      nnoremap('<Leader>gn', gs.next_hunk)
      nnoremap('<Leader>gN', gs.prev_hunk)
      nnoremap('<Leader>gS', gs.select_hunk)
      nnoremap('<Leader>gsh', gs.stage_hunk)
      nnoremap('<Leader>gsb', gs.stage_buffer)
      nnoremap('<Leader>grh', gs.reset_hunk)
      nnoremap('<Leader>grb', gs.reset_buffer)
      nnoremap('<Leader>guh', gs.undo_stage_hunk)
      nnoremap('<Leader>gub', gs.reset_buffer_index)
    end,
  }
}
