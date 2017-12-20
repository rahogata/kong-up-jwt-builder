local find = string.find

return {
  no_consumer = true, -- this plugin is available only on APIs.
  fields = {
    key = { required = true, type = "string", default = "" },
    alg = { required = false, type = "string", default = "HS256" },
    headers = { required = false, type = "array", default = {} }
    dailect = { required = false, type = "string", default = "http://konghq.com/claims/"}
    issuer = { required = false, type = "string", default = "konghq.com/plugins/up-jwt-builder"}
  }
}
