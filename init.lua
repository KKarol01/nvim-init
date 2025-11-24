-- ============================================================
-- Modern Neovim 0.11+ init.lua (Windows, C++ autocomplete)
-- Using new vim.lsp.config API (no lspconfig)
-- ============================================================

---------------------------------------------------------------
-- Bootstrap lazy.nvim
---------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false
vim.o.termguicolors = true
vim.o.lazyredraw = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.guifont = "ComicMonoNF:h11"


---------------------------------------------------------------
-- Plugins
---------------------------------------------------------------
require("lazy").setup({
  -- LSP (no lspconfig required now)
  { "neovim/nvim-lspconfig" },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
	  "hrsh7th/cmp-nvim-lsp-signature-help",
    },
  },

  -- UI stuff
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-lualine/lualine.nvim", dependencies = { 'nvim-tree/nvim-web-devicons' } },
  
  { 
	'Civitasv/cmake-tools.nvim',
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
  },
  
  { "Mofiqul/vscode.nvim" },
  
  {
    'nvim-telescope/telescope.nvim',
     dependencies = { 'nvim-lua/plenary.nvim' }
  },
  
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },
  
  {'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },
  
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
  	-- add any custom options here
    }
  },
  
  {
    'numToStr/Comment.nvim',
    opts = {

    }
  },
  
})

---------------------------------------------------------------
-- Treesitter
---------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "cmake", "json" },
  highlight = { enable = true },
})

require("cmake-tools").setup({
	cmake_command = "cmake",
    cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1", "-GNinja" },
	cmake_build_directory = function()
		local osys = require("cmake-tools.osys")
		if osys.iswin32 then
			return "build\\${variant:buildType}"
		end
	end,
    cmake_compile_commands_options = {
		action = "copy", 
		target = vim.loop.cwd(),
	},
})

---------------------------------------------------------------
-- Completion: nvim-cmp
---------------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
  completion = { completeopt = 'menu,menuone,noinsert' },

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
	{ name = "nvim_lsp_signature_help" },
  },
  
  window = {
	completion = cmp.config.window.bordered(),
  },
})

require('lualine').setup()

-- setup CTRL+/ to toggle line-style comments for c/c++ for both visual and normal modes
require('Comment').setup({
    toggler = {
        ---Line-comment toggle keymap
      line = '<C-/>',
    },
    ---LHS of operator-pending mappings in NORMAL and VISUAL mode
	opleader = {
	  line = '<C-/>',
	},
})
 -- Set only line comment
local ft = require('Comment.ft')
ft({'c', 'cpp'}, '//%s')

local capabilities = require("cmp_nvim_lsp").default_capabilities()

---------------------------------------------------------------
-- LSP: Modern Neovim >=0.11 API (NO lspconfig wrapper)
---------------------------------------------------------------
vim.lsp.config["clangd"] = {
  cmd = { "clangd", "--background-index", "-completion-style=detailed" },
  capabilities = capabilities,
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },

  init_options = {
    clangdFileStatus = true,
    usePlaceholders = false,
    completeUnimported = true,
  },
}
vim.lsp.enable("clangd")

require("nvim-tree").setup({
	git = {
		enable = true,
	},
	renderer = {
		highlight_git = true,
		icons = { 
			show = {
				git = true,
			},
		},
	},
	view = {
		side = "right",
	},
})

require("telescope").setup()

-- visual studio find symbol
vim.keymap.set("n", "<C-,>", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>")
-- visual studio find text (fucked up by weird regexp syntax)
vim.keymap.set("n", "<C-S-f>", "<cmd>Telescope live_grep<cr>")
-- find all references
vim.keymap.set("n", "gD", "<cmd>Telescope lsp_references<cr>")
-- go to definition
vim.keymap.set("n", "gd", function()
	vim.lsp.buf.definition()
	return "zz<cr>"
end, { expr = true })
-- switch header/source
vim.keymap.set("n", "<M-o>", "<cmd>LspClangdSwitchSourceHeader<cr>")
-- open up explorer and jump to
vim.keymap.set("n", "<M-;>", "<cmd>NvimTreeFindFile<cr>")
-- visual studio compile and run
vim.keymap.set("n", "<F5>", "<cmd>CMakeRun<cr>")
-- rename symbol
vim.keymap.set("n", "<F2>", function()
	vim.lsp.buf.rename()
end)
-- visual studio build 
vim.keymap.set("n", "<C-S-b>", "<cmd>CMakeBuild<cr>")
-- format file
vim.keymap.set("n", "<M-f>", function()
	vim.lsp.buf.format()
end)
-- disable '/' selection highlight
vim.keymap.set("n", "<Esc>", function()
	if vim.v.hlsearch == 1 then
		vim.cmd("nohlsearch")
		return ""
	end
	return "<Esc>"
end, { expr = true, noremap = true })
-- switch to different tab(buffer; '[b')
vim.keymap.set("n", "<C-PageUp>", "<cmd>BufferPrevious<cr>")
vim.keymap.set("n", "<C-PageDown>", "<cmd>BufferNext<cr>")
-- close tab(buffer, really)
vim.keymap.set("n", "<M-w>", "<cmd>BufferClose<cr>")
-- jump to left/right window with cursor
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- save all files
vim.keymap.set("n", "<C-s>", "<cmd>wa<cr>")
-- load session for current dir with '\qs'. wanted to do it with autocmd, but LSP wouldn't work
vim.keymap.set("n", "<leader>qs", function()
  require("persistence").load()
end)

vim.cmd("colorscheme vscode")