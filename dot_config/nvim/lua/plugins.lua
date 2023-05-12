-- colorscheme
local nord = {
  'shaunsingh/nord.nvim',
  lazy = false,
  priority = 1000,
  config = function ()
    vim.g.nord_borders = true
    vim.g.nord_italic = false
    require('nord').set()
  end,
}

-- telescope
local telescope = {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'gbrlsnchs/telescope-lsp-handlers.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-telescope/telescope-symbols.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  event = 'VeryLazy',
  config = function ()
    local telescope = require('telescope')
    telescope.setup({
      extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown({}) },
      },
    })
    telescope.load_extension('fzf')
    telescope.load_extension('lsp_handlers')
    telescope.load_extension('ui-select')
  end,
}

-- which-key
local whichKey = {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {},
}

-- usage tweaks
local lastplace = {
  'ethanholz/nvim-lastplace',
  event = 'BufReadPre',
  opts = {},
}

local gitsigns = {
  'lewis6991/gitsigns.nvim',
  event = 'BufRead',
  opts = {},
}

local comment = {
  'numToStr/Comment.nvim',
  event = 'BufRead',
  opts = {},
}

-- status and buffer bars
local lualine = {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-navic',
    'gitsigns.nvim',
  },
  event = 'VeryLazy',
  opts = {
    options = {
      theme = 'nord',
      component_separators = { left = ' ', right = ' ' },
      section_separators = { left = ' ', right = ' ' },
    },
    tabline = {
      lualine_a = {
        { 'buffers', show_filename_only = false },
      },
    },
    sections = {
      lualine_a = {
        { 'mode' },
      },
      lualine_b = {
        { 'filename', fmt = function () return vim.fn.expand('%:~:.') end },
      },
      lualine_c = {
        { 'diagnostics' },
        { function () return require('nvim-navic').get_location() end, cond = function () return package.loaded['nvim-navic'] and require('nvim-navic').is_available() end },
      },
      lualine_x = {},
      lualine_y = {
        { 'b:gitsigns_head', icon = '' },
        { 'diff', source = function () if vim.b.gitsigns_status_dict then return { added = vim.b.gitsigns_status_dict.added, modified = vim.b.gitsigns_status_dict.changed, removed = vim.b.gitsigns_status_dict.removed } end end },
      },
      lualine_z = {
        { 'location' },
      },
    },
  },
}

-- treesitter
local treesitter = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = 'BufReadPost',
  opts = {
    ensure_installed = {
      'bash',
      'javascript',
      'lua',
      'markdown',
      'markdown_inline',
      'regex',
      'typescript',
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  },
  config = function (_, opts)
    require('nvim-treesitter.configs').setup(opts)
  end,
}

-- lsp
local navic = {
  'SmiteshP/nvim-navic',
  name = 'nvim-navic',
}

local mason = {
  'williamboman/mason.nvim',
  cmd = 'Mason',
  keys = {
    { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' },
  },
  opts = {
    ui = {
      border = 'rounded',
    },
  },
}

local null_ls = {
  'jose-elias-alvarez/null-ls.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  event = 'BufReadPre',
  config = function ()
    local nullls = require('null-ls')
    nullls.setup({
      sources = {
        nullls.builtins.formatting.prettier.with({
          condition = function (utils)
            return utils.root_has_file({ '.prettierrc' })
          end,
          only_local = "node_modules/.bin",
        }),
      },
    })
  end,
}

local lspconfig = {
  'neovim/nvim-lspconfig',
  dependencies = {
    'mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'nvim-navic',
  },
  event = 'BufReadPre',
  opts = {
    icons = {
      Error = '󰅚 ',
      Warn = '󰀪 ',
      Hint = '󰌶 ',
      Info = '󰋽 ',
    },
    diagnostics = {
      flat = {
        border = 'rounded',
        focusable = false,
      },
      severity_sort = true,
      signs = true,
      virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        source = 'if_many',
        spacing = 2,
      },
    },
    border = 'rounded',
    ensure_installed = {
      'eslint',
      'jsonls',
      'lua_ls',
      'tsserver',
    },
    on_attach = function (client, buffer)
      if client.server_capabilities.documentSymbolProvider then
        require('nvim-navic').attach(client, buffer)
      end

      local function map (mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
      end

      map('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })
      if client.server_capabilities.signatureHelpProvider then
        map('n', 'gK', vim.lsp.buf.signature_help, { desc = 'Signature help' })
      end
    end,
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = {'vim'},
            },
          },
        },
      },
      tsserver = {
        on_attach = function (client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
        end,
      },
    },
  },
  config = function (_, opts)
    vim.diagnostic.config(opts.diagnostics)

    if opts.icons then
      for type, icon in pairs(opts.icons) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end

    if opts.border then
      require('lspconfig.ui.windows').default_options = {
        border = opts.border,
      }
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = opts.border })
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = opts.border })
    end

    require('mason-lspconfig').setup({
      ensure_installed = opts.ensure_installed,
    })

    require('mason-lspconfig').setup_handlers({
      function (server)
        local server_opts = {}
        server_opts.on_attach = function (client, bufnr)
          if opts.on_attach then
            opts.on_attach(client, bufnr)
          end

          if opts.servers[server] and opts.servers[server].on_attach then
            opts.servers[server].on_attach(client, bufnr)
          end
        end

        for k, v in pairs(opts.servers[server] or {}) do
          if k ~= 'on_attach' then
            server_opts[k] = v
          end
        end

        require('lspconfig')[server].setup(server_opts)
      end
    })
  end,
}


return {
  nord,
  telescope,
  whichKey,
  lastplace,
  gitsigns,
  comment,
  lualine,
  treesitter,
  navic,
  mason,
  null_ls,
  lspconfig,
}
