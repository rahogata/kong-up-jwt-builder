local jwt_encoder = require "kong.plugins.up-jwt-builder.jwt_encoder"
local req_get_headers = ngx.req.get_headers
local req_set_header = ngx.req.set_header
local string_find = string.find
local ngx_time = ngx.time

local reserved_claims = {
    JWT_ISS = "iss",
    JWT_AUD = "aud",
    JWT_EXP = "exp",
    JWT_JTI = "jti",
    JWT_IAT = "iat",
    JWT_NBF = "nbf"
}

local _M = {}

local function parse_json(header_value)
  if body then
    local status, res = pcall(cjson.decode, header_value)
    if status then
      return res
    end
  end
end

local function header(conf)
  return {typ = "JWT", alg = conf.alg}
end

-- construct jwt payload
-- orig_header_value comma separated claim=value pairs
local function payload(conf, orig_header_value)
--get actual value convert it to table
-- for each claim name get it's value from table.
  local data = parse_json(orig_header_value)
  if data == nil -- assume key=value pairs
  	data = {}
  	for k, v in orig_header_value:gmatch'(%w+)=(%w+)' do
  		data[conf.dialect .. k] = v
  	end
  else
	for k, v in pairs(data) do 
	  data[conf.dialect .. k] = v
	  data[k] = nil
	end
  end
  data[reserved_claims.JWT_ISS] = conf.issuer
  data[reserved_claims.JWT_AUD] = ngx.var.upstream_host
  data[reserved_claims.JWT_IAT] = ngx_time()
  return data
end

local function setjwttoken(conf)
  for i, name in ipairs(conf.headers) do
  	if req_get_headers()[name] then
      local data = payload(conf, req_get_headers()[name])
      local token, err = jwt_encoder.encode(data, conf.key, conf.alg, header(conf))
      if token then
      	req_set_header(name, token)
      end
    end
  end
end

function _M.execute(conf)

  if ngx.ctx.authenticated_credential and conf.anonymous ~= "" then
    -- we're already authenticated, and we're configured for using anonymous, 
    -- hence we're in a logical OR between auth methods and we're already done.
    return
  end

  if ngx.req.get_method() == "POST" then
    local uri = ngx.var.uri

    local from, _ = string_find(uri, "/oauth2/token", nil, true)

    if from then
      setjwttoken(conf)
    end
  end
end