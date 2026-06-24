-- ~/.config/nvim/init.lua

vim.g.mapleader      = "\\"
vim.g.maplocalleader = "\\"

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

-- Bar cursor in all modes
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

vim.opt.wildmenu    = true
vim.opt.wildmode    = "longest:full,full"
vim.opt.completeopt = "menu,menuone,noselect"

vim.opt.updatetime = 250
vim.opt.timeoutlen = 1000   -- same relaxed pace as tmux prefix
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

    -- Open files shown as tabs at the top
    { "echasnovski/mini.tabline", version = false, lazy = false,
      config = function() require("mini.tabline").setup() end },

    -- Floating centered file explorer (\e) — same plugin as the screenshot
    { "folke/snacks.nvim", priority = 1000, lazy = false,
      opts = {
          -- Only the picker is used (for the explorer tree)
          picker       = { enabled = true },
          explorer     = { enabled = false },
          bigfile      = { enabled = false },
          dashboard    = { enabled = false },
          indent       = { enabled = false },
          input        = { enabled = false },
          notifier     = { enabled = false },
          quickfile    = { enabled = false },
          scope        = { enabled = false },
          scroll       = { enabled = false },
          statuscolumn = { enabled = false },
          words        = { enabled = false },
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

    -- Autocomplete — auto-triggers, Ctrl+n/p to navigate, Enter to accept
    { "saghen/blink.cmp", version = "1.*", event = { "InsertEnter", "LspAttach" },
      opts = {
          keymap  = {
              preset   = "default",
              ["<CR>"] = { "select_and_accept", "fallback" },
          },
          sources = { default = { "lsp", "path", "buffer" } },
      } },

    -- Multi-cursor: Ctrl+n on a word, repeat to add next match, Ctrl+Up/Down adds line
    { "mg979/vim-visual-multi", branch = "master" },

}, {
    ui               = { border = "rounded" },
    install          = { colorscheme = { "catppuccin", "habamax" } },
    checker          = { enabled = false },
    change_detection = { notify = false },
})

-- Re-enforce bar cursor after all plugins load (prevents plugin overrides)
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function() vim.opt.guicursor = "a:ver25" end,
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
        map("K",         vim.lsp.buf.hover)
        map("gd",        vim.lsp.buf.definition)
        map("gr",        vim.lsp.buf.references)
        map("<leader>r", vim.lsp.buf.rename)
        map("<leader>a", vim.lsp.buf.code_action)
    end,
})

vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })

-- ── Key mappings — all actions use \ prefix ──────────────────────────────────

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- \ prefix — every user action (Esc first if in insert mode)
vim.keymap.set("n", "<leader>s", "<cmd>write<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>e", function()
    Snacks.picker.explorer({
        layout = {
            layout = {
                backdrop  = false,
                width     = 0.45,
                min_width = 50,
                height    = 0.85,
                border    = "rounded",
                box       = "vertical",
                title     = " Explorer ",
                title_pos = "center",
                { win = "list",  border = "none" },
                { win = "input", height = 1, border = "top" },
            },
        },
    })
end, { desc = "Explorer" })
vim.keymap.set("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close file" })
vim.keymap.set("n", "<leader>Q", "<cmd>qall!<CR>",   { desc = "Quit all" })

-- Window focus — \ prefix only, no Ctrl in normal mode
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Window right" })

-- Switch open files
vim.keymap.set("n", "<Tab>",   "<cmd>bnext<CR>",     { desc = "Next file" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Prev file" })

-- Visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
