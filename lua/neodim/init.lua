local new_layout = require("neodim.management").new_layout
local next_layout = require("neodim.management").next_layout
local prev_layout = require("neodim.management").prev_layout
local shift_layout_front = require("neodim.management").shift_layout_front
local shift_layout_back = require("neodim.management").shift_layout_back
local snapshots_picker = require("neodim.telescope").snapshots_picker

vim.keymap.set("n", "<leader>tt", snapshots_picker, { silent = true })
vim.keymap.set("n", "<leader>T", new_layout, { silent = true })
vim.keymap.set("n", "<leader>tn", next_layout, { silent = true })
vim.keymap.set("n", "<leader>tN", shift_layout_front, { silent = true })
vim.keymap.set("n", "<leader>tp", prev_layout, { silent = true })
vim.keymap.set("n", "<leader>tP", shift_layout_back, { silent = true })
vim.keymap.set("n", "<leader>tr", snapshots_picker, { silent = true })
