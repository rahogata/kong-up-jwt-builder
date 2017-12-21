local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.up-jwt-builder.access"

local UpJwtHandler = BasePlugin:extend()

function UpJwtHandler:new()
  UpJwtHandler.super.new(self, "up-jwt-builder")
end

function UpJwtHandler:access(conf)
  UpJwtHandler.super.access(self)
  access.execute(conf)
end

UpJwtHandler.PRIORITY = 1005
UpJwtHandler.VERSION = "0.1.0"

return UpJwtHandler
