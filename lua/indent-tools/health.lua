local M = {}

M.check = function()
  vim.health.start("Indent Tool Health Check")
  if not pcall(require, "arshlib") then
    vim.health.error("arshlib.nvim was not found", {
      'Please install "arsham/arshlib.nvim"',
    })
  else
    vim.health.ok("arshlib.nvim is installed")
  end
end

return M
