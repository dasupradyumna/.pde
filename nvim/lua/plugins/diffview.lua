------------------------------------------- DIFFVIEW.NVIM ------------------------------------------

return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<Leader>gd', '<Cmd>DiffviewOpen<CR>', noremap = true },
    { '<Leader>gh', '<Cmd>DiffviewFileHistory<CR>', noremap = true },
    { '<Leader>gH', '<Cmd>DiffviewFileHistory ', noremap = true },
  },
  config = function()
    local act = require 'diffview.config'.actions
    require('diffview').setup {
      enhanced_diff_hl = true,
      view = { merge_tool = { layout = 'diff4_mixed' } },
      file_history_panel = { win_config = { position = 'top' } },
      commit_log_panel = { win_config = { border = 'rounded' } },
      hooks = {},
      keymaps = {
        disable_defaults = true,
        view = {
          q = act.close,
          ['<Leader>f'] = act.focus_files,
          ['<Leader>F'] = act.toggle_files,
          ['<S-Tab>'] = act.select_prev_entry,
          ['<Tab>'] = act.select_next_entry,
          -- CHECK: if below mappings work in a merge conflict state
          ['<Leader>gmn'] = act.next_conflict,
          ['<Leader>gmN'] = act.prev_conflict,
          ['<Leader>gmb'] = act.conflict_choose 'base',
          ['<Leader>gmo'] = act.conflict_choose 'ours',
          ['<Leader>gmt'] = act.conflict_choose 'theirs',
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
}
