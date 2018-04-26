local jwt_encoder = require "kong.plugins.up-jwt-builder.jwt_encoder"
local utils = require "kong.tools.utils"
local cjson = require "cjson"
local req_get_headers = ngx.req.get_headers
local req_set_header = ngx.req.set_header
local ngx_time = ngx.time
local string_gmatch = string.gmatch
local pcall = pcall

local reserved_claims = {
  ISS = "iss",
  AUD = "aud",
  EXP = "exp",
  IAT = "iat",
  SUB = "sub",
  NBF = "nbf",
  JTI = "jti"
}

local _M = {}

local function parse_json(header_value)
  if header_value then
    local status, res = pcall(cjson.decode, header_value)
    if status then
      return res
    end
  end
end

-- construct jwt payload
-- orig_header_value comma separated claim=value pairs
local function payload_of(conf, orig_header_value)

  local data = {}

  local value = parse_json(orig_header_value)
  local iter_func
  if value == nil then --key=value pairs
    iter_func = string_gmatch
    value = orig_header_value
  else
    iter_func = pairs
  end
    for k, v in iter_func(value, '([^=]+)=*([^,]+),*') do -- either takes value or pattern based on orig_header_value
      data[conf.dialect .. k] = v
    end
    for k, v in pairs(reserved_claims) do
      data[v] = data[conf.dialect .. v]
      data[conf.dialect .. v] = nil
    end
  -- add registered claims from the configuration, may overwrite by header values
  data[reserved_claims.ISS] = data[reserved_claims.ISS] and data[reserved_claims.ISS] or conf.issuer
  data[reserved_claims.AUD] = data[reserved_claims.AUD] and data[reserved_claims.AUD] or (conf.audience or ngx.var.upstream_host)
  data[reserved_claims.IAT] = data[reserved_claims.IAT] and data[reserved_claims.IAT] or ngx_time()
  data[reserved_claims.EXP] = data[reserved_claims.EXP] and data[reserved_claims.EXP] or (conf.expiration and ngx_time() + conf.expiration or nil)
  return data
end

local function setjwttoken(conf)
  for i, name in ipairs(conf.headers) do
    if req_get_headers()[name] then
      local data = payload_of(conf, req_get_headers()[name])
      local token, err = jwt_encoder.encode(data, conf.key, conf.alg)
      if token then
      	req_set_header(name, token)
      end
    end
  end
end

function _M.execute(conf)

  if ngx.ctx.authenticated_credential then
    -- we're authenticated so jwt added already.
    return
  end

  -- set jwt token to authentication request.
  setjwttoken(conf)
end

return _M
