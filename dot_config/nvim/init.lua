-- install packer if necessary
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

-- autocmd to sync plugins when saving this file
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerSync',
  group = vim.api.nvim_create_augroup('Packer', { clear = true }),
  pattern = 'init.lua',
})

-- load and configure plugins
require('packer').startup({function (use)
  -- self manage packer updates
  use {'wbthomason/packer.nvim'}

  -- theme
  use {'shaunsingh/nord.nvim',
    config = function ()
      vim.g.nord_borders = true
      vim.g.nord_italic = false
      require('nord').set()
    end,
  }

  -- keymap documentation window
  use {'folke/which-key.nvim',
    config = function ()
      require('which-key').setup({
        window = {
          border = 'rounded',
        },
        plugins = {
          spelling = { enabled = true },
        },
      })
    end,
  }

  -- fancier windows
  use {'stevearc/dressing.nvim'}

  -- statusline and bufferline
  use {'nvim-lualine/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      'SmiteshP/nvim-navic',
    },
    config = function ()
      local navic = require('nvim-navic')
      navic.setup()

      local diff_source = function ()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
          }
        end
      end

      local filetype_fmt = function ()
        return vim.fn.expand('%:~:.')
      end

      require('lualine').setup({
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
            { 'filetype', icon_only = false, fmt = filetype_fmt },
          },
          lualine_c = {
            { 'diagnostics' },
            { navic.get_location, cond = navic.is_available },
          },
          lualine_x = {
          },
          lualine_y = {
            { 'b:gitsigns_head', icon = '' },
            { 'diff', source = diff_source },
          },
          lualine_z = {
            { 'location' },
          },
        },
      })
    end,
  }

  -- remember last place in this file
  use {'ethanholz/nvim-lastplace',
    config = function ()
      require('nvim-lastplace').setup()
    end,
  }

  -- enhanced marks
  use {'chentoast/marks.nvim',
    config = function ()
      require('marks').setup()
    end,
  }

  -- git integration
  use {'lewis6991/gitsigns.nvim',
    config = function ()
      require('gitsigns').setup({
        on_attach = function (bufnr)
          local gs = package.loaded.gitsigns
          local wk = require('which-key')

          wk.register({
            name = '+git',
            s = { '<cmd>Gitsigns stage_hunk<cr>', 'Stage hunk' },
            r = { '<cmd>Gitsigns reset_hunk<cr>', 'Reset hunk' },
            S = { gs.stage_buffer, 'Stage buffer' },
            u = { gs.undo_stage_hunk, 'Undo stage hunk' },
            R = { gs.reset_buffer, 'Reset buffer' },
            p = { gs.preview_hunk, 'Preview hunk' },
            b = { function () gs.blame_line({ full = true }) end, 'Blame line' },
            d = { gs.diffthis, 'Git diff' },
          }, { prefix = '<leader>h', mode = 'n' })

          wk.register({
            ['ih'] = { '<cmd>Gitsigns select_hunk<cr>', 'Git hunk' },
          }, { mode = { 'x', 'o' } })
        end,
      })
    end,
  }

  -- comment and surround
  use {'echasnovski/mini.nvim',
    config = function ()
      require('mini.comment').setup({
        hooks = {
          pre = function ()
            require('ts_context_commentstring.internal').update_commentstring()
          end,
        },
      })
    end,
  }

  -- treesitter support
  use {'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    run = ':TSUpdate',
    config = function ()
      require('nvim-treesitter.configs').setup({
        context_commentstring = {
          enable = true,
          enable_autocmd = false, -- for comment plugin integration
        },
        ensure_installed = {
          "bash",
          "javascript",
          "lua",
          "markdown",
          "markdown_inline",
          "regex",
          "typescript",
        },
        highlight = { enable = true },
        indent = { enable = false },
        incremental_selection = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
      })

      -- some of the keys are automatically picked up, for some reason these aren't
      -- so they're documented manually here
      local wk = require('which-key')
      wk.register({
        [']]'] = 'Next class start',
        [']['] = 'Next class end',
        ['[['] = 'Previous class start',
        ['[]'] = 'Previous class end',
      })

      wk.register({
        ['af'] = 'entire function',
        ['if'] = 'function contents',
        ['ac'] = 'entire class',
        ['ic'] = 'class contents',
      }, { mode = 'o' })

      wk.register({
        a = 'Swap with next argument',
        A = 'Swap with previous argument',
      }, { prefix = "<leader>" })
    end,
  }

  -- lsp support
  use {'williamboman/nvim-lsp-installer',
    requires = { 'neovim/nvim-lspconfig' },
    config = function ()
      -- make diagnostics less noisy
      vim.diagnostic.config({
        virtual_text = {
          severity = { min = vim.diagnostic.severity.WARN },
          source = 'if_many',
          spacing = 2,
        },
        signs = false,
        float = {
          border = 'rounded',
          focusable = false,
        },
        severity_sort = true,
      })

      require('lspconfig.ui.windows').default_options = {
        border = 'rounded',
      }

      -- put a border around signature help and hover
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
      })

      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = 'rounded',
      })

      local server_opts = {
        ['tsserver'] = function (opts)
          local _on_attach = opts.on_attach
          opts.on_attach = function (client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            _on_attach(client, bufnr)
          end
          opts.cmd = {'npm', 'exec', '--yes', '--package=typescript-language-server@latest', '--package=typescript', '--', 'typescript-language-server', '--stdio'}
        end,
      }

      require('nvim-lsp-installer').on_server_ready(function (server)
        local opts = {
          on_attach = function (client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
              require('nvim-navic').attach(client, bufnr)
            end

            local wk = require('which-key')
            wk.register({
              d = {
                name = 'diagnostics',
                n = { vim.diagnostic.goto_next, 'Go to next' },
                p = { vim.diagnostic.goto_prev, 'Go to previous' },
              },
              l = {
                name = 'lsp',
                a = { vim.lsp.buf.code_action, 'Code action' },
                D = { vim.lsp.buf.declaration, 'Declaration' },
                d = { vim.lsp.buf.definition, 'Definition' },
                i = { vim.lsp.buf.implementation, 'Implementation' },
                I = { vim.lsp.buf.incoming_calls, 'Incoming calls' },
                O = { vim.lsp.buf.outgoing_calls, 'Outgoing calls' },
                t = { vim.lsp.buf.type_definition, 'Type definition' },
                r = { vim.lsp.buf.references, 'References' },
                s = { vim.lsp.buf.document_symbol, 'Symbols (document)' },
                S = { function ()
                  vim.ui.input({ prompt = "Symbol" }, function (input)
                    vim.lsp.buf.workspace_symbol(input)
                  end)
                end, 'Symbol (workspace)' },
              },
            }, { prefix = '<leader>', buffer = bufnr })

            wk.register({
              K = { vim.lsp.buf.hover, 'Hover help' },
              ['<C-k>'] = { vim.lsp.buf.signature_help, 'Signature help' },
              ['<M-k>'] = { vim.lsp.buf.signature_help, 'Signature help', mode = 'i' },
            }, { buffer = bufnr })
          end,
          settings = {
            Lua = {
              diagnostics = {
                globals = {'vim'},
              },
            },
          },
        }

        if server_opts[server.name] then
          server_opts[server.name](opts)
        end

        server:setup(opts)
      end)
    end,
  }
end,
  config = {
    -- put updates in a floating window
    display = {
      open_fn = function ()
        return require('packer.util').float({ border = 'rounded' })
      end,
    },
  }})

-- change the leader to ,
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- enable mouse
vim.o.mouse = 'a'

-- yank to clipboard
vim.o.clipboard = 'unnamedplus'

-- expand tabs to 2 spaces
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

-- highlight the current line
vim.o.cursorline = true

-- disable the mode line
vim.o.showmode = false

-- disable bells
vim.o.visualbell = false

-- persistent undo
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath('data')..'/undo'
vim.o.undolevels = 1000
vim.o.undoreload = 10000

-- case insensitive search unless capital used
vim.o.ignorecase = true
vim.o.smartcase = true

-- neovide settings
if vim.g.neovide then
  vim.o.guifont = 'Hack Nerd Font Mono:h14'
  vim.g.neovide_scroll_animation_length = 0.0
  vim.g.neovide_cursor_animation_length = 0.0
end
