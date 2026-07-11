require("lazy").setup({

  --  theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },

  --  telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  --  file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  --  treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate'
  },
  --  LSP support
  {
    "neovim/nvim-lspconfig",
  },

  {
    "williamboman/mason.nvim",
    config = true,
  },

  {
    "williamboman/mason-lspconfig.nvim",
  },

  --  autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
  },

  --  git integration
  {
    "lewis6991/gitsigns.nvim",
    config = true,
  },

  --  statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
  },

  --  useful editor plugins
  "tpope/vim-commentary",
  "tpope/vim-surround",
  "tpope/vim-fugitive",

   --  code compoanion
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    opts = {
      adapters = {
        http = {
          qwen = function()
            return require("codecompanion.adapters").extend(
              "openai_compatible",
              {
                env = {
                  url = "OPENAI_BASE_URL",
                  api_key = "OPENAI_API_KEY",
                },
              }
            )
          end,
        },
      },

      strategies = {
        chat = { adapter = "qwen" },
        inline = { adapter = "qwen" },
        cmd = { adapter = "qwen" },
      },
    },
    dependencies = {
      "ravitemer/mcphub.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  }, 
})
