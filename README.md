# snaptab

Add a new dimension to your tab layouts

## Introduction

I like to work with tabs a lot. Usually I find myself overloaded with tabs, some with some terminals with long running commands, a few layouts for the workspace I'm working on. And sometimes, I need to context switch to a different project for a bit, and need to open some layouts there. If this is for a nontrivial task, I normally end up clearing my tabs, which I then need to restore when I switch back.

Many people will solve this by using multiple nvim instances running on different windows / tmux sessions. But I like to work with a single instance of nvim and everything to live inside it. So to deal with this I've created this plugin.

snaptab allows you save and restore your current tabs layout in its entirety. It captures all buffers, windows, sizes, cursor positions... for all your tabs, for you to restore later. It also lets you manage these snapshots by cycling through them (or opening them from telescope if you have it).

## Installation

Here's my lazy config to install it:
<details>
  <summary>Lazy</summary>

```lua
  {
    "alvarosevilla95/snaptab",
    config = function()
      local snaptab = require("snaptab")
      vim.keymap.set("n", "<leader>tt", snaptab.snapshots_picker)
      vim.keymap.set("n", "<leader>T", snaptab.new_snapshot)
      vim.keymap.set("n", "<leader>tj", snaptab.next_snapshot)
      vim.keymap.set("n", "<leader>tJ", snaptab.shift_snapshot_front)
      vim.keymap.set("n", "<leader>tk", snaptab.prev_snapshot)
      vim.keymap.set("n", "<leader>tK", snaptab.shift_snapshot_back)
      vim.keymap.set("n", "<leader>tr", snaptab.rename_current_snapshot)
      vim.keymap.set("n", "<leader>dh", snaptab.delete_buffers_not_in_any_snapshot)

      local group_id = vim.api.nvim_create_augroup("snaptabSession", { clear = true })

      -- Sync snapshots with vim session on exit
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group_id,
        pattern = "*",
        callback = function()
          local session = vim.v.this_session
          if vim.v.this_session ~= "" then
            local layout_file = session:gsub(".vim$", ".vim.layout")
            vim.fn.writefile({ snaptab.serialize_state() }, layout_file)
          end
        end,
      })

      -- Restore snapshots on session load
      vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = group_id,
        pattern = "*",
        callback = function()
          local session = vim.v.this_session
          if vim.v.this_session ~= "" then
            local layout_file = session:gsub(".vim$", ".vim.layout")
            if vim.fn.filereadable(layout_file) then
              local json_str = vim.fn.readfile(layout_file)[1]
              snaptab.restore_state(json_str)
            end
          end
        end,
      })
    end,
  }
```

</details>
It loads snaptab, sets up the mappings I use, and I also configure autocommands to sync the state of the plugin with my vim session.

## Usage

As shown above, the API exposed by the plugin consists of:

* `require("snaptab").new_snapshot`: Saves the current layout and creates a new one (added to the end of the snapshots list). The new snapshot is created with a single tab / window focused on the current buffer
* `require("snaptab").next_snapshot`: Saves the current layout and switches to the next one in the list (looping back as needed)
* `require("snaptab").prev_snapshot`: Same but goes back in the list
* `require("snaptab").shift_snapshot_front`: Shifts the current snapshot down the list
* `require("snaptab").shift_snapshot_back`: Shifts the current snapshot up the list
* `require("snaptab").rename_current_snapshot`: Renames the current snapshot (asks for input)
* `require("snaptab").snapshots_picker`: Opens the snapshot list in telescope (if installed). In normal mode (default), `dd` deletes the selected snapshot (if it's not the current one). `r` renames the snapshot and `<CR>` opens the snapshot. In insert mode only <CR>` is mapped
* `require("snaptab").delete_buffers_not_in_any_snapshot`: A bit niche but I use it. It wipes all buffers not currently opened in any snapshot (not just the current one)


