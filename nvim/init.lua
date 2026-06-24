-- ~/.config/nvim/init.lua

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Disable netrw (replaced by nvim-tree)
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
vim.opt.laststatus     = 3  -- single global statusline

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

    -- Persistent side-panel file explorer (no layout bugs)
    { "nvim-tree/nvim-tree.lua", lazy = false,
      config = function()
          require("nvim-tree").setup({
              view    = { width = 30 },
              filters = { dotfiles = false },
              git     = { enable = true },
              renderer = { group_empty = true, highlight_git = true },
          })
          vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle explorer" })
          -- Quit nvim when nvim-tree is the only window left
          vim.api.nvim_create_autocmd("BufEnter", {
              callback = function()
                  if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
                      vim.defer_fn(function() vim.cmd("quit") end, 0)
                  end
              end,
          })
      end },

    -- Bottom statusline
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
          require("lspconfig").pyright.setup({
              settings = { python = { analysis = { typeCheckingMode = "basic" } } },
          })
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
        if vim.fn.argc() == 0 or
           (vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1) then
            require("nvim-tree.api").tree.open()
        end
    end,
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
