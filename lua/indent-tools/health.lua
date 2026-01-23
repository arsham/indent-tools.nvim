local M = {}

local libs = {
  {
    name = "arshlib",
    lib = "arsham/arshlib.nvim",
    fn = vim.health.error,
  },
  {
    names = {
      "nvim-treesitter-textobjects.repeatable_move",
      "nvim-treesitter.textobjects.repeatable_move",
    },
    lib = "nvim-treesitter/nvim-treesitter-textobjects",
    fn = vim.health.warn,
  },
}

M.check = function()
  vim.health.start("Indent Tool Health Check")
  for _, package in ipairs(libs) do
    local names = package.names or { package.name }
    local ok = false
    for _, name in ipairs(names) do
      ok = pcall(require, name)
      if ok then
        break
      end
    end
    if not ok then
      package.fn(package.lib .. " was not found", {
        'Please install "' .. package.lib .. '"',
      })
    else
      vim.health.ok(package.lib .. " is installed")
    end
  end
end

return M
