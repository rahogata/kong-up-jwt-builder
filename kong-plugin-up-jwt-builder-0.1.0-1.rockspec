package = "kong-plugin-up-jwt-builder"
                                 
version = "0.1.0-1"
local pluginName = package:match("^kong%-plugin%-(.+)$")

supported_platforms = {"linux", "macosx"}
source = {
  url = "git+https://github.com/shiva2991/kong-up-jwt-builder"
}

description = {
  summary = "A Kong plugin to send additional information after authentication as JWT in the upstream header provided by authentication plugins.",
  homepage = "https://github.com/shiva2991/kong-up-jwt-builder",
  license = "MIT"
}

dependencies = {}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
    ["kong.plugins."..pluginName..".asn_sequence"] = "kong/plugins/"..pluginName.."/asn_sequence.lua",
    ["kong.plugins."..pluginName..".jwt_encoder"] = "kong/plugins/"..pluginName.."/jwt_encoder.lua",
    ["kong.plugins."..pluginName..".access"] = "kong/plugins/"..pluginName.."/access.lua"
  }
}
