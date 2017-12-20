-- JWT token generating module
-- Adapted version of x25/luajwt for Kong. It provides various improvements and
-- an OOP architecture allowing the JWT to be parsed and verified separatly,
-- avoiding multiple parsings.
--
-- @see https://github.com/x25/luajwt

local json = require "cjson"
local crypto = require "crypto"
local asn_sequence = require "kong.plugins.up-jwt-builder.asn_sequence"

local error = error
local type = type
local table_concat = table.concat
local encode_base64 = ngx.encode_base64

--- Supported algorithms for signing tokens.
local alg_sign = {
  ["HS256"] = function(data, key) return crypto.hmac.digest("sha256", data, key, true) end,
  --["HS384"] = function(data, key) return crypto.hmac.digest("sha384", data, key, true) end,
  --["HS512"] = function(data, key) return crypto.hmac.digest("sha512", data, key, true) end
  ["RS256"] = function(data, key) return crypto.sign('sha256', data, crypto.pkey.from_pem(key, true)) end,
  ["RS512"] = function(data, key) return crypto.sign('sha512', data, crypto.pkey.from_pem(key, true)) end,
  ["ES256"] = function(data, key)
    local pkeyPrivate = crypto.pkey.from_pem(key, true)
    local signature = crypto.sign('sha256', data, pkeyPrivate)

    local derSequence = asn_sequence.parse_simple_sequence(signature)
    local r = asn_sequence.unsign_integer(derSequence[1], 32)
    local s = asn_sequence.unsign_integer(derSequence[2], 32)
    assert(#r == 32)
    assert(#s == 32)
    return r .. s
  end
}

--- base 64 encoding
-- @param input String to base64 encode
-- @return Base64 encoded string
local function b64_encode(input)
  local result = encode_base64(input)
  result = result:gsub("+", "-"):gsub("/", "_"):gsub("=", "")
  return result
end

-- Encode data to JWT.
local function encode_token(data, key, alg, header)
  if type(data) ~= "table" then
    error("Argument #1 must be table", 2)
  end
  if type(key) ~= "string" then
    error("Argument #2 must be string", 2)
  end
  if header and type(header) ~= "table" then
    error("Argument #4 must be a table", 2)
  end

  alg = alg or "HS256"

  if not alg_sign[alg] then
    error("Algorithm not supported", 2)
  end

  local header = header or {typ = "JWT", alg = alg}
  local segments = {
    b64_encode(json.encode(header)),
    b64_encode(json.encode(data))
  }

  local signing_input = table_concat(segments, ".")
  local signature = alg_sign[alg](signing_input, key)
  segments[#segments+1] = b64_encode(signature)
  return table_concat(segments, ".")
end

--[[

  JWT public interface

]]--

local _M = {}
_M.__index = _M

--- Instansiate a JWT encoder.
-- Construct JWT token of given data.
-- Return errors instead of an instance if any encountered.
-- @param token JWT to parse
-- @return JWT parser
-- @return error if any
function _M:new(data, key, alg, header)
  return encode_token(data, key, alg, header)
end

_M.encode = encode_token

return _M
