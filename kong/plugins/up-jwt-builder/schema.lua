return {
  no_consumer = true, -- this plugin is available only on APIs.
  fields = {
    key = { required = true, type = "string", default = "" },
    alg = { required = false, type = "string", default = "HS256" },
    headers = { required = false, type = "array", default = {} },
    dialect = { required = false, type = "string", default = "http://example.com/claims/" },
    issuer = { required = false, type = "string", default = "example.com/plugins/up-jwt-builder" },
    audience = { required = false, type = "string" },
    expiration = { required = false, type = "number"}
  }
}
