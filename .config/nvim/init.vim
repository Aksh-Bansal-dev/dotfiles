set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

lua << EOF
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    local tasks = {
        {"run neofetch", "neofetch"},
        {"print hello", "echo hiiiii"},
        {"python serve", "python3 -m http.server"}
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
            vim.cmd(string.format("tabe | term %s",selection.value[2]))
          end)
          return true
        end,
      }):find()
    end

EOF
