-- module represents a lua module for the plugin
local M = {}
local curl = require("plenary.curl")

M.get_staged_diff = function()
  local handle = io.popen("git diff --cached")
  if not handle then
    error("Cannot open git diff command")
  end
  local diff_output = handle:read("*a")
  handle:close()
  if diff_output == "" then
    error("No staged files found")
  end
  return diff_output
end

M.build_payload_file = function(diff, prompt)
  if not prompt then
    error("No prompt found")
  end
  local payload = {
    model = "gpt-3.5-turbo",
    messages = {
      {
        role = "system",
        content = prompt,
      },
      {
        role = "user",
        content = diff,
      },
    },
  }
  TMP_MSG_FILENAME = os.tmpname()
  local f = io.open(TMP_MSG_FILENAME, "w+")

  if f == nil then
    error("Cannot open temporary message file: " .. TMP_MSG_FILENAME)
  end

  f:write(vim.json.encode(payload))

  f:close()
  return TMP_MSG_FILENAME
end

M.generate_text = function(payload_filename, token)
  if not token then
    error("No token found")
  end

  local result = curl.post({
    url = "https://api.openai.com/v1/chat/completions",
    body = payload_filename,
    headers = {
      authorization = "Bearer " .. token,
      content_type = "application/json",
    },
  })

  if not result or not result.body then
    error("Cannot open curl command")
  end
  local result_body = result.body

  if result_body == "" then
    error("No response from OpenAI API")
  end
  local json = vim.json.decode(result_body)
  if not json.choices then
    error("No choices found in response")
  end

  local message = json.choices[1].message.content

  return message
end

M.build_commit_file = function(message)
  TMP_COMMIT_FILENAME = os.tmpname()
  local f = io.open(TMP_COMMIT_FILENAME, "w+")
  if f == nil then
    error("Cannot open temporary commit file: " .. TMP_COMMIT_FILENAME)
  end
  f:write(message)
  f:close()

  return TMP_COMMIT_FILENAME
end

return M
