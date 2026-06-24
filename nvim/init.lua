-- ~/.config/nvim/init.lua — minimal, no plugins

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

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

-- Cursor — bar cursor universally (all modes including no-file startup)
vim.opt.guicursor = "a:ver25"

-- Colour
vim.cmd("colorscheme habamax")

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
    extension = {
        cfg  = "dosini",
        conf = "dosini",
    },
    filename = {
        [".env"]          = "sh",
        ["Dockerfile"]    = "dockerfile",
    },
    pattern = {
        [".*%.env%.[%w_]+"] = "sh",     -- .env.production, .env.local, …
        [".*/%.ssh/config"] = "sshconfig",
    },
})

vim.g.is_bash = 1

-- File explorer
vim.g.netrw_banner       = 0
vim.g.netrw_liststyle    = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv         = 1
vim.g.netrw_winsize      = 25
vim.g.netrw_fastbrowse   = 0  -- disable dir caching; prevents ghost buffers after open/close
vim.g.netrw_keepdir      = 0  -- keep cwd in sync with explorer

vim.keymap.set("n", "<leader>e", "<cmd>Lexplore<CR>", { desc = "Toggle explorer" })

-- Auto-open explorer: no args → current dir (like `code .`); dir arg → that dir
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd("Lexplore")
        elseif vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
            vim.cmd("Lexplore " .. vim.fn.fnameescape(vim.fn.argv(0)))
        end
    end,
})

-- LSP — Python via pyright (install: brew install pyright)
vim.api.nvim_create_autocmd("FileType", {
    pattern  = { "python" },
    callback = function()
        vim.lsp.start({
            name     = "pyright",
            cmd      = { "pyright-langserver", "--stdio" },
            root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", "requirements.txt", ".git" }),
            settings = { python = { analysis = { typeCheckingMode = "basic" } } },
        })
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local buf = args.buf
        if vim.lsp.completion then  -- nvim 0.11+ built-in autocomplete
            vim.lsp.completion.enable(true, args.data.client_id, buf, { autotrigger = true })
        end
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
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>",     { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>",   { desc = "Delete buffer" })
