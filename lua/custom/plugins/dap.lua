return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'leoluz/nvim-dap-go',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
    },
    config = function()
      local dap = require 'dap'
      local ui = require 'dapui'

      require('dapui').setup()
      require('dap-go').setup()

      require('nvim-dap-virtual-text').setup {
        -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match 'secret' or name:match 'api' or value:match 'secret' or value:match 'api' then
            return '*****'
          end

          if #variable.value > 15 then
            return ' ' .. string.sub(variable.value, 1, 15) .. '... '
          end

          return ' ' .. variable.value
        end,
      }

      -- Handled by nvim-dap-go
      -- dap.adapters.go = {
      --   type = "server",
      --   port = "${port}",
      --   executable = {
      --     command = "dlv",
      --     args = { "dap", "-l", "127.0.0.1:${port}" },
      --   },
      -- }

      dap.adapters.coreclr = {
        type = 'executable',
        command = '/home/dhurgham/.config/nvim/builds/netcoredbg/netcoredbg/netcoredbg',
        args = { '--interpreter=vscode' },
      }

      dap.configurations.netrw = {
        {
          type = 'coreclr',
          name = 'launch - netcoredbg',
          request = 'launch',
          justMyCode = false,
          stopAtEntry = true,
          program = function()
            return vim.fn.input('Path ', vim.fn.getcwd(), 'file')
          end,
          cwd = function()
            return vim.fn.input('WD ', vim.fn.getcwd(), 'file')
          end,
        },
      }

      dap.configurations.cs = {
        {
          type = 'coreclr',
          name = 'launch - netcoredbg',
          request = 'launch',
          justMyCode = false,
          stopAtEntry = true,
          program = function()
            return vim.fn.input('Path ', vim.fn.getcwd(), 'file')
          end,
          cwd = function()
            return vim.fn.input('WD ', vim.fn.getcwd(), 'file')
          end,
        },
      }

      local elixir_ls_debugger = vim.fn.exepath 'elixir-ls-debugger'
      if elixir_ls_debugger ~= '' then
        dap.adapters.mix_task = {
          type = 'executable',
          command = elixir_ls_debugger,
        }

        dap.configurations.elixir = {
          {
            type = 'mix_task',
            name = 'phoenix server',
            task = 'phx.server',
            request = 'launch',
            projectDir = '${workspaceFolder}',
            exitAfterTaskReturns = false,
            debugAutoInterpretAllModules = false,
          },
        }
      end

      vim.keymap.set('n', '<space>b', dap.toggle_breakpoint)
      vim.keymap.set('n', '<space>gb', dap.run_to_cursor)

      -- Eval var under cursor
      vim.keymap.set('n', '<space>?', function()
        require('dapui').eval(nil, { enter = true })
      end)

      vim.keymap.set('n', '<F5>', dap.continue)
      vim.keymap.set('n', '<F11>', dap.step_into)
      vim.keymap.set('n', '<F10>', dap.step_over)
      vim.keymap.set('n', '<F7>', dap.step_out)
      vim.keymap.set('n', '<F8>', dap.step_back)
      vim.keymap.set('n', '<F12>', dap.restart)
      vim.keymap.set('n', '<F6>', dap.terminate)
      vim.keymap.set('n', '<F9>', dap.toggle_breakpoint)

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
