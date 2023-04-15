-- module represents a lua module for the plugin
local M = {}
local job = require("plenary.job")

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

M.generate_text = function(payload_filename, token, callback)
  if not token then
    error("No token found")
  end

  job
    :new({
      command = "curl",
      args = {
        "--silent",
        "-X",
        "POST",
        "-H",
        "Content-Type: application/json",
        "-H",
        "Authorization: Bearer " .. token,
        "--data",
        "@" .. payload_filename,
        "https://api.openai.com/v1/chat/completions",
      },
      on_exit = function(result, code)
        vim.schedule(function()
          if code ~= 0 then
            print("Error: curl failed. Error code: " .. return_code)
            return
          end

          local result_body = table.concat(result:result(), "\n")
          local json = vim.json.decode(result_body)
          if not json.choices then
            error("No choices found in response")
          end
          local text = json.choices[1].message.content
          callback(text)
        end)
      end,
    })
    :start()
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
