local plugin = require("acommit")

describe("setup", function()
  it("works with default", function()
    assert("my first function with param = Hello!", plugin.commit())
  end)

  it("works with custom var", function()
    plugin.setup({ opt = "custom" })
    assert("my first function with param = custom", plugin.commit())
  end)
end)
