local module = require("acommit.module")
local stub = require("luassert.stub")

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
