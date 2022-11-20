local quick = require("arshlib.quick")

---Returns the indentation of the next line from the given argument, that is
-- not empty. All lines are trimmed before examination.
---@param from number the line number to start from.
---@param step number if positive, the next line is traversed, otherwise the
-- previous line.
---@param barier number the maximum I will check. Can be 0 or max lines.
---@return number the indentation of the next line.
local function next_unempty_line(from, step, barier) --{{{
  for i = from, barier, step do
    local len = #string.gsub(vim.fn.getline(i), "^%s+", "")
    if len > 0 then
      return vim.fn.indent(i)
    end
  end
  return 0
end
--}}}

---Jumps to the next indentation level equal to current line. It skips empty
-- lines, unless the next non-empty line has a lower indentation level. If the
-- previous indentation is equal to the current one, and current indentation is
-- higher than the nest, it will stop.
---@param down boolean indicates whether we are jumping down.
local function jump_indent(down) --{{{
  local main_loc = vim.api.nvim_win_get_cursor(0)[1]
  local main_len = #string.gsub(vim.fn.getline(main_loc), "^%s+", "")
  local main_indent = main_len > 0 and vim.fn.indent(main_loc) or 0
  local target = main_loc
  local barrier = down and vim.api.nvim_buf_line_count(0) or 0
  local step = down and 1 or -1
  local in_move = false

  for i = main_loc, barrier, step do
    local line_len = #string.gsub(vim.fn.getline(i), "^%s+", "")

    if line_len ~= 0 then
      -- Variable setup {{{
      -- stylua: ignore start
      local indent      = vim.fn.indent(i)
      local next_len    = #string.gsub(vim.fn.getline(i + step), "^%s+", "")
      local next_indent = next_len > 0 and vim.fn.indent(i + step) or 0
      local prev_empty  = #string.gsub(vim.fn.getline(i - step), "^%s+", "") == 0
      local prev_indent = prev_empty and 0 or vim.fn.indent(i - step)
      local far_indent  = next_unempty_line(i + step*2, step, barrier)

      local on_main_level      = indent        ==  main_indent
      local cruising           = on_main_level and in_move
      local same_level         = indent        ==  prev_indent
      local leveling_up        = indent        >   prev_indent
      local will_go_up         = indent        <   next_indent
      local may_go_up_the_main = next_indent   >=  main_indent
      local will_go_down       = indent        >   next_indent
      local goes_down_the_main = next_indent   <   main_indent
      local later_will_go_down = indent        >   far_indent
      local later_lower_main   = main_indent   >   far_indent
      local prev_not_empty     = next_len      ~=  0
      local next_is_empty      = next_len      ==  0
      local road_block         = will_go_down  and prev_not_empty
      -- stylua: ignore end
      --}}}

      if later_will_go_down and next_is_empty and later_lower_main then
        break
      elseif same_level and on_main_level then
        if road_block then
          -- the next line also coule be empty.
          break
        elseif in_move then
          if will_go_up or goes_down_the_main then
            break
          end
        end
      elseif leveling_up then
        if cruising and prev_empty then
          break
        elseif not may_go_up_the_main and prev_not_empty then
          break
        end
      elseif cruising then
        break
      elseif road_block and not in_move then
        break
      end
    end

    in_move = true
    target = i + step
  end

  local sequence = string.format("%dgg_", target)
  quick.normal("xt", sequence)
end
-- }}}

---Selects all lines with equal or higher indents to the current line in line
-- visual mode. It ignores any empty lines.
-- @param around boolean? if true it will include empty lines around the
-- indentation.
local function in_indent(around) --{{{
  local cur_line = vim.api.nvim_win_get_cursor(0)[1]
  local cur_indent = vim.fn.indent(cur_line)
  local total_lines = vim.api.nvim_buf_line_count(0)

  local first_line = cur_line
  local first_non_empty_line = cur_line
  for i = cur_line, 0, -1 do
    if cur_indent == 0 and #vim.fn.getline(i) == 0 then
      -- If we are at column zero, we will stop at an empty line.
      break
    end
    if #vim.fn.getline(i) ~= 0 then
      local indent = vim.fn.indent(i)
      if indent < cur_indent then
        break
      end
      first_non_empty_line = i
    end
    first_line = i
  end

  local last_line = cur_line
  local last_non_empty_line = cur_line
  for i = cur_line, total_lines, 1 do
    if cur_indent == 0 and #vim.fn.getline(i) == 0 then
      break
    end
    if #vim.fn.getline(i) ~= 0 then
      local indent = vim.fn.indent(i)
      if indent < cur_indent then
        break
      end
      last_non_empty_line = i
    end
    last_line = i
  end

  if not around then
    first_line = first_non_empty_line
    last_line = last_non_empty_line
  end
  local sequence = string.format("%dgg0o%dgg$V", first_line, last_line)
  quick.normal("xt", sequence)
end
--}}}

local defaults = { --{{{
  normal = { up = "[i", down = "]i" },
  textobj = { ii = "ii", ai = "ai" },
}
--}}}

local function setup_textobj(opts)
  vim.validate({
    opts = { opts, "table" },
    ii = { opts.ii, { "string", "nil", "boolean" } },
    ai = { opts.ai, { "string", "nil", "boolean" } },
  })

  if opts.ii then
    local o = { silent = true, desc = "in indentation block" }
    vim.keymap.set("x", opts.ii, function()
      in_indent(false)
    end, o)
    vim.keymap.set("o", opts.ii, function()
      quick.normal("x", "v" .. opts.ii)
    end, o)
  end

  if opts.ai then
    local o = { silent = true, desc = "around indentation block" }
    vim.keymap.set("x", opts.ai, function()
      in_indent(true)
    end, o)
    vim.keymap.set("o", opts.ai, function()
      quick.normal("x", "v" .. opts.ai)
    end, o)
  end
end

return {
  config = function(opts) --{{{
    opts = vim.tbl_deep_extend("force", defaults, opts)
    vim.validate({
      opts = { opts, "table" },
      normal = { opts.normal, { "table", "nil", "boolean" } },
      normal_up = { opts.normal.up, { "string", "nil", "boolean" } },
      normal_down = { opts.normal.down, { "string", "nil", "boolean" } },
      textobj = { opts.textobj, { "table", "nil", "boolean" } },
    })

    if opts then
      if opts.normal then
        if opts.normal.down then
          vim.keymap.set("n", opts.normal.down, function()
            jump_indent(true)
          end, { desc = "jump down along the indent" })
        end

        if opts.normal.up then
          vim.keymap.set("n", opts.normal.up, function()
            jump_indent(false)
          end, { desc = "jump up along the indent" })
        end
      end

      if opts.textobj then
        setup_textobj(opts.textobj)
      end
    end
  end,
  --}}}
}

-- vim: fdm=marker fdl=0
