------------------------------------- SOURCE CONTROL MANAGEMENT ------------------------------------

return {
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      attach_to_untracked = true,
      current_line_blame = true,
      current_line_blame_opts = { delay = 250 },
      current_line_blame_formatter = '    <author> (<author_time>) :: <summary>',
      current_line_blame_formatter_nc = '    [ not committed ]',
      numhl = true,
      signcolumn = false,

      on_attach = function(bufnr)
        local function nmap(lhs, rhs) vim.keymap.set('n', lhs, rhs, { buffer = bufnr }) end
        local gs = require 'gitsigns'
        nmap('<Leader>gl', gs.toggle_current_line_blame)
        nmap('<Leader>gp', gs.preview_hunk_inline)
        nmap('<Leader>gn', gs.next_hunk)
        nmap('<Leader>gN', gs.prev_hunk)
        nmap('<Leader>gS', gs.select_hunk)
        nmap('<Leader>gsh', gs.stage_hunk)
        nmap('<Leader>gsb', gs.stage_buffer)
        nmap('<Leader>grh', gs.reset_hunk)
        nmap('<Leader>grb', gs.reset_buffer)
        nmap('<Leader>guh', gs.undo_stage_hunk)
        nmap('<Leader>gub', gs.reset_buffer_index)
      end,
    },
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<Leader>gd', '<Cmd>DiffviewOpen<CR>', noremap = true },
      { '<Leader>gh', '<Cmd>DiffviewFileHistory<CR>', noremap = true },
      { '<Leader>gH', ':DiffviewFileHistory ', noremap = true },
    },
    config = function()
      local act = require('diffview.config').actions
      local lib = require 'diffview.lib'
      require('diffview').setup {
        enhanced_diff_hl = true,
        view = { merge_tool = { layout = 'diff4_mixed', winbar_info = false } },
        file_history_panel = { win_config = { position = 'top' } },
        commit_log_panel = { win_config = { border = 'rounded' } },
        hooks = {
          view_opened = function()
            vim.opt_local.signcolumn = 'no'
            vim.t.diffview_toplevel_dir = lib.get_current_view().adapter.ctx.toplevel
          end,
          diff_buf_read = function() vim.opt_local.signcolumn = 'no' end,
          view_enter = function() require('gitsigns').toggle_current_line_blame(false) end,
          view_leave = function() require('gitsigns').toggle_current_line_blame(true) end,
        },
        keymaps = {
          disable_defaults = true,
          view = {
            q = act.close,
            ['<Leader>f'] = act.focus_files,
            ['<Leader>F'] = act.toggle_files,
            -- CHECK: if below mappings work in a merge conflict state
            ['<Leader>gmn'] = act.next_conflict,
            ['<Leader>gmN'] = act.prev_conflict,
            ['<Leader>gmb'] = act.conflict_choose 'base',
            ['<Leader>gmc'] = act.conflict_choose 'ours', -- current
            ['<Leader>gmi'] = act.conflict_choose 'theirs', -- incoming
          },
          -- TODO: lot of common panel keymaps; check if plugin offers a 'panel' attribute
          file_panel = {
            gc = act.open_commit_log,
            gf = act.goto_file_tab,
            h = act.close_fold,
            l = act.select_entry,
            q = act.close,
            r = act.restore_entry,
            s = act.toggle_stage_entry,
            S = act.stage_all,
            U = act.unstage_all,
            ['<C-D>'] = act.scroll_view(0.1),
            ['<C-R>'] = act.refresh_files,
            ['<C-U>'] = act.scroll_view(-0.1),
            ['<Leader>F'] = act.toggle_files,
            ['<Leader>gmn'] = act.next_conflict,
            ['<Leader>gmN'] = act.prev_conflict,
            ['<S-Tab>'] = act.select_prev_entry,
            ['<Tab>'] = act.select_next_entry,
          },
          file_history_panel = {
            gc = act.open_commit_log,
            gf = act.goto_file_tab,
            go = act.options,
            h = act.close_fold,
            l = act.select_entry,
            q = act.close,
            y = act.copy_hash,
            ['<C-D>'] = act.scroll_view(0.1),
            ['<C-R>'] = act.refresh_files,
            ['<C-U>'] = act.scroll_view(-0.1),
            ['<Leader>F'] = act.toggle_files,
            ['<Leader>gd'] = act.open_in_diffview,
          },
          option_panel = { q = act.close },
          help_panel = { q = act.close },
        },
      }
    end,
  },
}
