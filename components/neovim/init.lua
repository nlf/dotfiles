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

  -- gruvbox theme
  use {'ellisonleao/gruvbox.nvim',
    config = function ()
      vim.opt.background = 'dark'
      vim.cmd('colorscheme gruvbox')
      -- link the MarkSignHL highlight group to GruvboxOrangeSign
      vim.highlight.link('MarkSignHL', 'GruvboxOrangeSign', true)
    end,
  }

  -- fancier windows
  use {'stevearc/dressing.nvim'}

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
      require('gitsigns').setup()
    end,
  }

  -- keymap documentation window
  use {'folke/which-key.nvim',
    config = function ()
      local wk = require('which-key')
      wk.setup({
        window = {
          border = 'rounded',
        },
      })

      local Terminal = require('term')
      local term = Terminal:new()

      local open = function ()
        term:open()
      end

      local close = function ()
        term:close()
      end

      local focus_last = function ()
        term:focus_last()
      end

      wk.register({
        ['<leader>t'] = { open, 'Open terminal' },
        ['<leader>y'] = { close, 'Close terminal' },
      }, { mode = 'n' })

      wk.register({
        ['<esc><esc>'] = { focus_last, 'Focus last window' },
        ['<esc>y'] = { close, 'Close terminal' },
      }, { mode = 't' })
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

      local comment_after_line = function ()
        local line = vim.fn.line('.')
        local text = vim.fn.printf(vim.api.nvim_buf_get_option(0, 'commentstring'), ' ')
        vim.fn.append(line, text)
        vim.cmd('startinsert')
        vim.api.nvim_win_set_cursor(0, { line + 1, #text + 1 })
      end

      local comment_before_line = function ()
        local line = vim.fn.line('.')
        local text = vim.fn.printf(vim.api.nvim_buf_get_option(0, 'commentstring'), ' ')
        vim.fn.append(line - 1, text)
        vim.cmd('startinsert')
        vim.api.nvim_win_set_cursor(0, { line, #text + 1 })
      end

      local comment_end_of_line = function ()
        local line = vim.fn.line('.')
        local text = vim.fn.getline(line) .. ' ' .. vim.fn.printf(vim.api.nvim_buf_get_option(0, 'commentstring'), ' ')
        vim.fn.setline(line, text)
        vim.cmd('startinsert')
        vim.api.nvim_win_set_cursor(0, { line, #text + 1 })
      end

      local wk = require('which-key')
      wk.register({
        c = {
          name = "Comment",
          c = 'Toggle line comment',
          A = { comment_end_of_line, 'Add comment at end of line' },
          o = { comment_after_line, 'Add comment on next line' },
          O = { comment_before_line, 'Add comment on previous line' },
        },
      }, { prefix = 'g' })

      wk.register({
        ['gc'] = 'Comment',
      }, { mode = 'o' })

      wk.register({
        ['gc'] = 'Comment',
      }, { mode = 'v' })
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
        ensure_installed = { "lua", "javascript", "typescript" },
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
          source = true,
        },
        signs = false,
        float = {
          border = 'rounded',
          focusable = false,
        },
      })

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
            client.resolved_capabilities.document_formatting = false
            _on_attach(client, bufnr)
          end
        end,
      }

      require('nvim-lsp-installer').on_server_ready(function (server)
        local opts = {
          on_attach = function (client, bufnr)
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
        }

        if server_opts[server.name] then
          server_opts[server.name](opts)
        end

        server:setup(opts)
      end)
    end,
  }

  -- telescope
  use {'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'gbrlsnchs/telescope-lsp-handlers.nvim',
    },
    config = function ()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ['<esc>'] = require('telescope.actions').close,
            },
          },
        },
      })

      -- HACK until the telescope-lsp-handlers package is patched, we wrap these two
      -- functions to ensure an encoding is passed so we don't get warnings logged
      local _jump_to_location = vim.lsp.util.jump_to_location
      vim.lsp.util.jump_to_location = function (opts, enc)
        local enc = enc or 'utf-8'
        return _jump_to_location(opts, enc)
      end
      local _locations_to_items = vim.lsp.util.locations_to_items
      vim.lsp.util.locations_to_items = function (items, enc)
        local enc = enc or 'utf-8'
        return _locations_to_items(items, enc)
      end
      telescope.load_extension('lsp_handlers')

      require('which-key').register({
        f = {
          name = 'Find...',
          b = { require('telescope.builtin').buffers, 'Buffers' },
          c = { require('telescope.builtin').commands, 'Commands' },
          f = { require('telescope.builtin').find_files, 'Files' },
          g = { require('telescope.builtin').live_grep, 'Live grep' },
        },
      }, { prefix = '<leader>' })
    end,
  }

  -- statusline and bufferline
  use {'nvim-lualine/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      'SmiteshP/nvim-gps',
    },
    config = function ()
      local gps = require('nvim-gps')
      gps.setup()

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
          theme = 'gruvbox',
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
            { gps.get_location, cond = gps.is_available },
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
