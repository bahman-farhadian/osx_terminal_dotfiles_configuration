-- ~/.config/nvim/init.lua — minimal, no plugins required

-- Leader key (set before any mappings)
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── Display ───────────────────────────────────────────────────────────────
vim.opt.number         = true   -- absolute line numbers
vim.opt.relativenumber = true   -- relative numbers for easy j/k jumps
vim.opt.cursorline     = true   -- highlight the current line
vim.opt.signcolumn     = "yes"  -- always show sign column (no layout shift)
vim.opt.wrap           = false  -- no line wrapping
vim.opt.scrolloff      = 8      -- keep 8 lines above/below cursor
vim.opt.sidescrolloff  = 8
vim.opt.colorcolumn    = "120"  -- soft right-margin guide

-- ── Colour ────────────────────────────────────────────────────────────────
vim.opt.termguicolors = true
vim.cmd("colorscheme habamax")  -- best built-in dark theme; no plugins needed

-- ── Indentation ───────────────────────────────────────────────────────────
vim.opt.tabstop     = 4   -- display width of a hard tab
vim.opt.shiftwidth  = 4   -- indent step
vim.opt.expandtab   = true -- insert spaces, not tabs
vim.opt.autoindent  = true
vim.opt.smartindent = true

-- ── Search ────────────────────────────────────────────────────────────────
vim.opt.ignorecase = true  -- case-insensitive search …
vim.opt.smartcase  = true  -- … unless pattern has an uppercase letter
vim.opt.hlsearch   = true
vim.opt.incsearch  = true

-- ── Files / buffers ───────────────────────────────────────────────────────
vim.opt.swapfile = false
vim.opt.backup   = false
vim.opt.undofile = true   -- persistent undo across sessions

-- ── Clipboard — sync with the OS clipboard ────────────────────────────────
vim.opt.clipboard = "unnamedplus"

-- ── Completion / command line ─────────────────────────────────────────────
vim.opt.wildmenu   = true
vim.opt.wildmode   = "longest:full,full"
vim.opt.completeopt = "menuone,noselect"

-- ── Split behaviour (mirrors tmux convention) ─────────────────────────────
vim.opt.splitright = true  -- new vertical split opens to the right
vim.opt.splitbelow = true  -- new horizontal split opens below

-- ── Miscellaneous ─────────────────────────────────────────────────────────
vim.opt.updatetime  = 250   -- faster CursorHold events
vim.opt.timeoutlen  = 300   -- ms to wait for mapped key sequences
vim.opt.mouse       = ""    -- disable mouse (keyboard-first workflow)
vim.opt.showmode    = false -- mode shown in statusline; not needed twice
vim.opt.laststatus  = 2     -- always show statusline

-- ── Key mappings ──────────────────────────────────────────────────────────

-- Clear search highlight with Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save and quit shortcuts
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>",  { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<CR>",   { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qall!<CR>",  { desc = "Quit all" })

-- Move between splits with Ctrl+hjkl (mirrors tmux Option+WASD)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus lower split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus upper split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right split" })

-- Stay in visual mode after indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Quick buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>",     { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>",   { desc = "Delete buffer" })

-- Open netrw (built-in file explorer) in tree style
vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>", { desc = "File explorer" })
vim.g.netrw_liststyle = 3  -- tree view by default
