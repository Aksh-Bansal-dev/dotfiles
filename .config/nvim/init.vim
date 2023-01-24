set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
" vim.cmd('source ~/.vimrc')

" Task runner
lua << EOF
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    local tasks = {
        {"markserv", "markserv", "RELATIVE_BUF_NAME"},
        {"python http serve", "python3 -m http.server", ""}
    }

    function runtask(opts)
      opts = opts or {}
      pickers.new(opts, {
        prompt_title = "colors",

        finder = finders.new_table {
          results=tasks,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry[1],
              ordinal = entry[1],
            }
          end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            -- print(vim.inspect(selection.value[1]))
            if selection.value[3] == "RELATIVE_BUF_NAME" then
                local relBufName = vim.fn.expand("%")
                vim.cmd(string.format("tabe | term %s %s",selection.value[2],relBufName))
            elseif selection.value[3] == "BUF_NAME" then
                local bufName = vim.api.nvim_buf_get_name(0)
                vim.cmd(string.format("tabe | term %s %s",selection.value[2],bufName))
            else
                vim.cmd(string.format("tabe | term %s",selection.value[2]))
            end
          end)
          return true
        end,
      }):find()
    end

    vim.api.nvim_set_keymap("n","<leader>rt",":lua runtask()<CR>", {noremap = true})
EOF
