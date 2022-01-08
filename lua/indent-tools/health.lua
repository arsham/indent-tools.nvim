local M = {}
local health = require("health")

M.check = function()
  health.report_start("Indent Tool Health Check")
  if not pcall(require, "arshlib") then
    health.report_error("arshlib.nvim was not found", {
      'Please install "arsham/arshlib.nvim"',
    })
  else
    health.report_ok("arshlib.nvim is installed")
  end
end

return M
