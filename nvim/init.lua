-- ~/.config/nvim/init.lua

vim.g.mapleader      = ","
vim.g.maplocalleader = ","

vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Display
vim.opt.number         = true
vim.opt.relativenumber = false
vim.opt.cursorline     = true
vim.opt.signcolumn     = "yes"
vim.opt.wrap           = false
vim.opt.scrolloff      = 8
vim.opt.sidescrolloff  = 8
vim.opt.colorcolumn    = "120"
vim.opt.termguicolors  = true
vim.opt.showmode       = false
vim.opt.laststatus     = 3
vim.opt.showtabline    = 2

vim.opt.guicursor = "a:ver25"

-- Indentation
vim.opt.tabstop     = 4
vim.opt.shiftwidth  = 4
vim.opt.expandtab   = true
vim.opt.autoindent  = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase  = true
vim.opt.hlsearch   = true
vim.opt.incsearch  = true

-- Files
vim.opt.swapfile  = false
vim.opt.backup    = false
vim.opt.undofile  = true
vim.opt.clipboard = "unnamedplus"

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Completion
vim.opt.wildmenu    = true
vim.opt.wildmode    = "longest:full,full"
vim.opt.completeopt = "menu,menuone,noselect"

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.mouse      = ""

-- Filetype detection
vim.filetype.add({
    extension = { cfg = "dosini", conf = "dosini" },
    filename  = { [".env"] = "sh", ["Dockerfile"] = "dockerfile" },
    pattern   = {
        [".*%.env%.[%w_]+"] = "sh",
        [".*/%.ssh/config"] = "sshconfig",
    },
})
vim.g.is_bash = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

    -- Catppuccin Mocha — matches terminal/Ghostty theme
    { "catppuccin/nvim", name = "catppuccin", priority = 1000,
      opts = { flavour = "mocha" },
      config = function(_, opts)
          require("catppuccin").setup(opts)
          vim.cmd.colorscheme("catppuccin")
      end },

    -- Buffer tabs at the top (shows open files like tmux windows)
    { "echasnovski/mini.tabline", version = false, lazy = false,
      config = function() require("mini.tabline").setup() end },

    -- Floating file / grep / buffer picker  (,f / ,g / ,b)
    { "echasnovski/mini.pick", version = false,
      keys = {
          { "<leader>f", function() require("mini.pick").builtin.files() end,      desc = "Find files" },
          { "<leader>g", function() require("mini.pick").builtin.grep_live() end,  desc = "Grep" },
          { "<leader>b", function() require("mini.pick").builtin.buffers() end,    desc = "Buffers" },
      } },

    -- Statusline
    { "nvim-lualine/lualine.nvim", event = "VeryLazy",
      opts = {
          options = {
              theme                = "catppuccin-mocha",
              icons_enabled        = false,
              component_separators = "|",
              section_separators   = "",
          },
          sections = {
              lualine_a = { "mode" },
              lualine_b = { "branch", "diff", "diagnostics" },
              lualine_c = { { "filename", path = 1 } },
              lualine_x = { "filetype" },
              lualine_y = { "progress" },
              lualine_z = { "location" },
          },
      } },

    -- Git signs in gutter
    { "lewis6991/gitsigns.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },

    -- LSP — pyright for Python (brew install pyright)
    { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" },
      config = function()
          vim.lsp.config("pyright", {
              settings = { python = { analysis = { typeCheckingMode = "basic" } } },
          })
          vim.lsp.enable("pyright")
      end },

    -- Autocomplete
    { "saghen/blink.cmp", version = "1.*", event = { "InsertEnter", "LspAttach" },
      opts = {
          keymap  = {
              preset        = "default",
              ["<CR>"]      = { "select_and_accept", "fallback" },
              ["<C-Space>"] = { "show", "fallback" },
          },
          sources = { default = { "lsp", "path", "buffer" } },
      } },

    -- Multi-cursor: Ctrl+n selects word, repeat to add next match, Ctrl+↑/↓ adds cursor
    { "mg979/vim-visual-multi", branch = "master" },

}, {
    ui               = { border = "rounded" },
    install          = { colorscheme = { "catppuccin", "habamax" } },
    checker          = { enabled = false },
    change_detection = { notify = false },
})

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local buf = args.buf
        local map = function(k, f) vim.keymap.set("n", k, f, { buffer = buf, silent = true }) end
        map("K",          vim.lsp.buf.hover)
        map("gd",         vim.lsp.buf.definition)
        map("gr",         vim.lsp.buf.references)
        map("<leader>r",  vim.lsp.buf.rename)
        map("<leader>a",  vim.lsp.buf.code_action)
    end,
})

vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })

-- ── Key mappings ─────────────────────────────────────────────────────────────

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>write<CR>",  { desc = "Save" })

-- Close current file / force quit all
vim.keymap.set("n", "<leader>q", "<cmd>bdelete<CR>",  { desc = "Close file" })
vim.keymap.set("n", "<leader>Q", "<cmd>qall!<CR>",    { desc = "Quit all" })

-- Switch files — Tab / Shift+Tab (mirrors tmux Shift+←/→)
vim.keymap.set("n", "<Tab>",   "<cmd>bnext<CR>",     { desc = "Next file" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Prev file" })

-- Window focus
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
