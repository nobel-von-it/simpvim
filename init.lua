vim.g.mapleader=' '

local vk = vim.keymap
local vo = vim.opt

-- block with commands
vk.set('i', 'jk', '<ESC>', {})
vk.set('n', 'n', vim.cmd.nohl, {})
vk.set('n', '<leader>e', vim.cmd.Ex, {})

-- block with options
vo.number=true
vo.relativenumber=true
vo.cursorline=true

vo.shiftwidth=2
vo.tabstop=2
vo.scrolloff=8
vo.expandtab=true
vo.ruler=true
vo.smarttab=true
vo.autoindent=true
vo.lazyredraw=true

vo.ignorecase=true
vo.smartcase=true
vo.swapfile = false
vo.backup = false


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vo.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({})

      local builtin = require('telescope.builtin')
      vk.set('n', '<leader>ff', builtin.find_files, {})
      vk.set('n', '<leader>fg', builtin.live_grep, {})
      vk.set('n', '<leader>fb', builtin.buffers, {})
      vk.set('n', '<leader>fh', builtin.help_tags, {})
      vk.set('n', '<leader>pws', function()
        local word = vim.fn.expand("<cword>")
        builtin.grep_string({ search = word })
      end)
      vk.set('n', '<leader>pWs', function()
        local word = vim.fn.expand("<cWORD>")
        builtin.grep_string({ search = word })
      end)
      vk.set('n', '<leader>ps', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end)
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- A list of parser names, or "all"
        ensure_installed = {
          "vimdoc", "javascript", "typescript", "c", "lua", "rust",
          "jsdoc", "bash", "go", "html", "css"
        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
        auto_install = true,

        indent = {
          enable = true
        },

        highlight = {
          -- `false` will disable the whole extension
          enable = true,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = { "markdown" },
        },
      })

      local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      treesitter_parser_config.templ = {
        install_info = {
          url = "https://github.com/vrischmann/tree-sitter-templ.git",
          files = {"src/parser.c", "src/scanner.c"},
          branch = "master",
        },
      }

      vim.treesitter.language.register("templ", "templ")
    end
  },
  {
    "rebelot/kanagawa.nvim",
    config = function ()
      vim.cmd.colorscheme("kanagawa")
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "j-hui/fidget.nvim",
    },

    config = function()
      local cmp = require('cmp')
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities()
      )

      require("fidget").setup({})
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "rust_analyzer",
          "gopls",
        },
        handlers = {
          function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup {
              capabilities = capabilities
            }
          end,

          ["lua_ls"] = function()
            local lspconfig = require("lspconfig")
            lspconfig.lua_ls.setup {
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = { version = "Lua 5.1" },
                  diagnostics = {
                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                  }
                }
              }
            }
          end,
        }
      })

      local cmp_select = { behavior = cmp.SelectBehavior.Select }

      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' }, -- For luasnip users.
        }, {
            { name = 'buffer' },
          })
      })

      vim.diagnostic.config({
        -- update_in_insert = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end
  },
  {
    'numToStr/Comment.nvim',
    lazy = false,
    config = function ()
      require('Comment').setup({})
    end
  },
  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup({
        icons = false,
      })
      vk.set("n", "<leader>tt", function()
        require("trouble").toggle()
      end)

      vk.set("n", "[t", function()
        require("trouble").next({skip_groups = true, jump = true});
      end)

      vk.set("n", "]t", function()
        require("trouble").previous({skip_groups = true, jump = true});
      end)

    end
  },
  {
    "fatih/vim-go"
  },
  {
    "rust-lang/rust.vim",
    build = ":RustFmt"
  }
})
