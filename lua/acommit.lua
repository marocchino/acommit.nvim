-- main module file
local module = require("acommit.module")

local M = {}
M.config = {
  prompt = "You are to act as the author of a commit message in git. Your mission is to create clean and comprehensive commit messages in the gitmoji convention with emoji and explain why a change was done. I'll send you an output of 'git diff --staged' command, and you convert it into a commit message. Add a short description of WHY the changes are done after the commit message. Don't start it with 'This commit', just describe the changes. Use the present tense. Commit title must not be longer than 74 characters.",
  token = os.getenv("OPENAI_API_KEY"),
}

M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.commit = function()
  local diff = module.get_staged_diff()
  local payload_filename = module.build_payload_file(diff, M.config.prompt)
  local text = module.generate_text(payload_filename, M.config.token)
  local tmp_filename = module.build_commit_file(text)
  vim.cmd("Git commit -t " .. tmp_filename)
end

return M
