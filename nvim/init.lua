-- ~/.config/nvim/init.lua

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Disable netrw before plugins load (replaced by mini.files)
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
vim.opt.laststatus     = 2

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

-- Misc
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

    -- File explorer — floating navigator, zero layout interference
    { "echasnovski/mini.files", lazy = false,
      opts = { windows = { preview = false, width_focus = 30 } },
      config = function(_, opts)
          require("mini.files").setup(opts)
          vim.keymap.set("n", "<leader>e", function()
              local mf = require("mini.files")
              if not mf.close() then mf.open(vim.api.nvim_buf_get_name(0), true) end
          end, { desc = "Toggle explorer" })
      end },

    -- Syntax highlighting (main branch — new API, no nvim-treesitter.configs)
    { "nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate",
      config = function()
          require("nvim-treesitter").install({
              "python", "bash", "lua", "yaml", "json", "dockerfile", "toml",
          })
          local skip = { minifiles = true, lazy = true, mason = true, [""] = true }
          vim.api.nvim_create_autocmd("FileType", {
              callback = function(args)
                  if skip[args.match] then return end
                  local lang = vim.treesitter.language.get_lang(args.match)
                  if lang then pcall(vim.treesitter.start, args.buf, lang) end
              end,
          })
      end },

    -- Git signs in gutter
    { "lewis6991/gitsigns.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },

    -- LSP — pyright for Python (brew install pyright)
    { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" },
      config = function()
          require("lspconfig").pyright.setup({
              settings = { python = { analysis = { typeCheckingMode = "basic" } } },
          })
      end },

    -- Autocomplete — blink.cmp (pre-built binary, no build step needed)
    { "saghen/blink.cmp", version = "1.*", event = { "InsertEnter", "LspAttach" },
      opts = {
          keymap  = {
              preset    = "default",
              ["<CR>"]  = { "select_and_accept", "fallback" },
              ["<C-Space>"] = { "show", "fallback" },
          },
          sources = { default = { "lsp", "path", "buffer" } },
      } },

}, {
    ui               = { border = "rounded" },
    install          = { colorscheme = { "catppuccin", "habamax" } },
    checker          = { enabled = false },
    change_detection = { notify = false },
})

-- Auto-open explorer on startup: no args → cwd, dir arg → that dir
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        if vim.fn.argc() == 0 then
            require("mini.files").open(vim.uv.cwd(), false)
        elseif vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
            require("mini.files").open(vim.fn.argv(0), false)
        end
    end,
})

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- LSP keymaps when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local buf = args.buf
        local map = function(k, f) vim.keymap.set("n", k, f, { buffer = buf, silent = true }) end
        map("K",          vim.lsp.buf.hover)
        map("gd",         vim.lsp.buf.definition)
        map("gr",         vim.lsp.buf.references)
        map("<leader>rn", vim.lsp.buf.rename)
        map("<leader>ca", vim.lsp.buf.code_action)
    end,
})

vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })

-- Key mappings
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>w", "<cmd>write<CR>",  { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<CR>",   { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qall!<CR>",  { desc = "Quit all" })

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>",     { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>",   { desc = "Delete buffer" })
