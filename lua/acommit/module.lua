-- module represents a lua module for the plugin
local M = {}

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

M.generate_text = function(diff, prompt, token)
  if not prompt then
    error("No prompt found")
  end
  if not token then
    error("No token found")
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
      }
    }
  }
  TMP_MSG_FILENAME = os.tmpname()

  local f = io.open(TMP_MSG_FILENAME, "w+")

  if f == nil then
    vim.notify("Cannot open temporary message file: " .. TMP_MSG_FILENAME, vim.log.levels.ERROR)

    return
  end

  f:write(vim.json.encode(payload))

  f:close()
  local curl_command = string.format([[
  curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer %s" \
  --data @%s \
  https://api.openai.com/v1/chat/completions
  ]], token, TMP_MSG_FILENAME)

  local result = io.popen(curl_command)
  local result_body = result:read("*all")
  -- {"id":"chatcmpl-72C05dX6r95hCJahUYZnnpDreb8Ow","object":"chat.completion","created":1680757141,"model":"gpt-3.5-turbo-0301","usage":{"prompt_tokens":1196,"completion_tokens":83,"total_tokens":1279},"choices":[{"message":{"role":"assistant","content":"📝 Added 'commit' method in module.lua and updated the plugin to use it as a command\n\nThe 'commit' method now generates a commit message which includes the 'prompt' and the differences between the repository and the staged content. It then sends the commit message to OpenAI's GPT-3 to generate a full commit message. The plugin has been updated to use the 'commit' method."},"finish_reason":"stop","index":0}]}
  result:close()

  local json = vim.json.decode(result_body)
  if not json.choices then
    error("No choices found in response")
  end

  local message = json.choices[1].message.content

  return message
end

M.generate_commit_message_file = function(message)
  TMP_COMMIT_FILENAME = os.tmpname()
  local f = io.open(TMP_COMMIT_FILENAME, "w+")
  if f == nil then
    vim.notify("Cannot open temporary commit file: " .. TMP_COMMIT_FILENAME, vim.log.levels.ERROR)


    return
  end
  f:write(message)
  f:close()

  return TMP_COMMIT_FILENAME
end

return M
