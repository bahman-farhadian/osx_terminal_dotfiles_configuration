-- ~/.config/nvim/init.lua — minimal, no plugins

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── Display ───────────────────────────────────────────────────────────────
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

-- ── Cursor — bar cursor universally (all modes including no-file startup) ──
vim.opt.guicursor = "a:ver25"

-- ── Colour ────────────────────────────────────────────────────────────────
vim.cmd("colorscheme habamax")

-- ── Indentation ───────────────────────────────────────────────────────────
vim.opt.tabstop     = 4
vim.opt.shiftwidth  = 4
vim.opt.expandtab   = true
vim.opt.autoindent  = true
vim.opt.smartindent = true

-- ── Search ────────────────────────────────────────────────────────────────
vim.opt.ignorecase = true
vim.opt.smartcase  = true
vim.opt.hlsearch   = true
vim.opt.incsearch  = true

-- ── Files ─────────────────────────────────────────────────────────────────
vim.opt.swapfile  = false
vim.opt.backup    = false
vim.opt.undofile  = true
vim.opt.clipboard = "unnamedplus"

-- ── Splits ────────────────────────────────────────────────────────────────
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ── Completion ────────────────────────────────────────────────────────────
vim.opt.wildmenu    = true
vim.opt.wildmode    = "longest:full,full"
vim.opt.completeopt = "menuone,noselect"

-- ── Misc ──────────────────────────────────────────────────────────────────
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.mouse      = ""

-- ── Filetype detection ────────────────────────────────────────────────────
-- Map extra extensions to known filetypes so syntax + indentation work
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

-- Bash: treat sh files as bash (most modern scripts use bash constructs)
vim.g.is_bash = 1

-- ── File explorer — netrw configured as a VSCode-style side panel ─────────
vim.g.netrw_banner       = 0      -- hide the top info banner
vim.g.netrw_liststyle    = 3      -- tree view
vim.g.netrw_browse_split = 4      -- open file in the previous (right) window
vim.g.netrw_altv         = 1      -- split vertically when pressing 'v'
vim.g.netrw_winsize      = 25     -- explorer takes 25% of the total width

-- <leader>e toggles the side-panel explorer (Lexplore is a built-in toggle)
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

-- ── Key mappings ──────────────────────────────────────────────────────────
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save / quit
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>",  { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<CR>",   { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qall!<CR>",  { desc = "Quit all" })

-- Split navigation (mirrors tmux Ctrl+b h/j/k/l)
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Visual mode — stay in mode after indent, move lines
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>",     { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>",   { desc = "Delete buffer" })
