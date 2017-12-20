package = "kong-plugin-up-jwt-builder"
                                 
version = "0.1.0-1"
local pluginName = package:match("^kong%-plugin%-(.+)$")

supported_platforms = {"linux", "macosx"}
source = {
  -- these are initially not required to make it work
  url = "git@github.com:shiva2991/kong-upstream-jwt-builder",
  tag = "0.1.0"
}

description = {
  summary = "My custom Kong plugin to construct JWT from configured header parameters to send it to upstream.",
  homepage = "http://rahogata.co.in",
  license = "MIT"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
  }
}
