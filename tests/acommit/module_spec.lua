local module = require("acommit.module")
local stub = require("luassert.stub")
local job = require("plenary.job")

describe("get_staged_diff", function()
  it("returns staged diff", function()
    stub(io, "popen")
    io.popen.returns({
      read = function()
        return "diff --git a/README.md b/README.md"
      end,
      close = function() end,
    })

    local diff = module.get_staged_diff()
    assert.are.equal("diff --git a/README.md b/README.md", diff)
  end)

  it("raise error when nil", function()
    stub(io, "popen")
    io.popen.returns(nil)

    assert.has_error(module.get_staged_diff, "Cannot open git diff command")
  end)

  it("raise error when no staged files found", function()
    stub(io, "popen")
    io.popen.returns({
      read = function()
        return ""
      end,
      close = function() end,
    })

    assert.has_error(module.get_staged_diff, "No staged files found")
  end)
end)

describe("build_payload_file", function()
  local diff = "diff --git a/README.md b/README.md"
  local prompt = "example prompt"
  it("returns payload file", function()
    stub(io, "open")
    io.open.returns({
      write = function() end,
      close = function() end,
    })

    local payload_file = module.build_payload_file(diff, prompt)
    assert.is_not_nil(payload_file)
  end)

  it("raise error when prompt is nil", function()
    assert.has_error(function()
      module.build_payload_file(diff, nil)
    end, "No prompt found")
  end)

  it("raise error when open failed", function()
    stub(io, "open")
    io.open.returns(nil)
    assert.has_error(function()
      module.build_payload_file(diff, prompt)
    end)
  end)
end)

describe("parse_response", function()
  local response = {
    result = function()
      return {
        [[
    {"id":"chatcmpl-72NosIXohW3hJekjKtXKJuyYgHxjI","object":"chat.completion","created":1680802574,"model":"gpt-3.5-turbo-0301","usage":{"prompt_tokens":322,"completion_tokens":54,"total_tokens":376},"choices":[{"message":{"role":"assistant","content":"🚀 Add test case for 'generate_text' function\n\nStub `io.popen` and test that `module.generate_text` returns the correct generated text from `io.popen`. \nThis is done to ensure that `generate_text` function works as intended."},"finish_reason":"stop","index":0}]}
  ]],
      }
    end,
  }
  local code = 0

  it("returns parsed response", function()
    local callback = function(text)
      assert.are.equal(
        "🚀 Add test case for 'generate_text' function\n\nStub `io.popen` and test that `module.generate_text` returns the correct generated text from `io.popen`. \nThis is done to ensure that `generate_text` function works as intended.",
        text
      )
    end
    module.parse_response(response, code, callback)
  end)

  it("raise error when non 0 error code", function()
    local code = 1

    local callback = function(_)
      error("Callback should not be called")
    end

    assert.has_error(function()
      module.parse_response(response, code, callback)
    end, "Error: curl failed. Error code: 1")
  end)

  it("handles missing choices in response", function()
    local response = {
      result = function()
        return {
          '{"no_choices": [{"message": {"content": "Hello, World!"}}]}',
        }
      end,
    }

    local code = 0

    local callback = function(_)
      error("Callback should not be called")
    end

    assert.has_error(function()
      module.parse_response(response, code, callback)
    end, "No choices found in response")
  end)
end)
-- describe("generate_text", function()
--   pending("returns generated text", function()
--   end)
-- end)

describe("build_commit_file", function()
  local message = "message"

  it("returns commit file", function()
    stub(io, "open")
    io.open.returns({
      write = function() end,
      close = function() end,
    })

    local commit_file = module.build_commit_file(message)
    assert.is_not_nil(commit_file)
  end)

  it("raise error when open failed", function()
    stub(io, "open")
    io.open.returns(nil)
    assert.has_error(function()
      module.build_commit_file(message)
    end)
  end)
end)
