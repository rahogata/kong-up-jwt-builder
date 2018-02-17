local helpers = require "spec.helpers"
local fixtures = require "spec.03-plugins.17-jwt.fixtures"
local jwt_parser = require "kong.plugins.jwt.jwt_parser"
local ngx_time = ngx.time

describe("Upstream Jwt Builder (access)", function()
  local client

  setup(function()
  	helpers.run_migrations()
  	local api1 = assert(helpers.dao.apis:insert { name = "api-1", hosts = { "test1.com" }, upstream_url = helpers.mock_upstream_url})

  	assert(helpers.dao.plugins:insert{
  		api_id = api1.id,
  		name = "up-jwt-builder",
  		config = {
  		key = fixtures.rs256_private_key,
  		alg = "RS256",
  		headers = {"x-authenticated_userid"},
		issuer = "tester"
  		}
  	})
  	assert(helpers.start_kong({
	    custom_plugins = "up-jwt-builder",
      	    nginx_conf = "spec/fixtures/custom_nginx.template",
    }))
  end)

  teardown(function()
    helpers.stop_kong()
  end)
  
  before_each(function()
  	client = helpers.proxy_client()
  end)

  after_each(function()
  	if client then client:close() end
  end)

  describe("send header as key=value pairs", function()
  	it("replace key=value with jwt token", function()
  	  local r = assert( client:send{
  		method = "POST",
  		path = "/post",
  		body = {},
  		headers = {
                 host = "test1.com",
  		 ["x-authenticated_userid"] = "user=rama,email=rama@ayodhya.com",
                 ["Content-Type"] = "application/json"
  		}
  	  })
  	  assert.response(r).has.status(200)
          local token = assert.request(r).has.header("x-authenticated_userid")
          local jwt = assert(jwt_parser:new(token))
          assert.True(jwt:verify_signature(fixtures.rs256_public_key))
  	end)
  end)

  describe("send header as json", function()
  	it("replace json with jwt token", function()
  	  local r = assert( client:send{
  	  	method = "POST",
  	  	path = "/post",
  	  	body = {},
  	  	headers = {
                  host = "test1.com",
  	  	  ["x-authenticated_userid"] = '{"user" : "rama", "email" : "rama@ayodhya.com"}',
                  ["Content-Type"] = "application/json"
  		}
  	  })
  	  assert.response(r).has.status(200)
          local token = assert.request(r).has.header("x-authenticated_userid")
          local jwt = assert(jwt_parser:new(token))
          assert.True(jwt:verify_signature(fixtures.rs256_public_key))
  	end)
  end)
  
  describe("send registered claims", function()
    it("configured claims overwritten", function()
	  local nbf = ngx_time() - 10
  	  local r = assert( client:send{
  	  	method = "POST",
  	  	path = "/post",
  	  	body = {},
  	  	headers = {
                  host = "test1.com",
  	  	  ["x-authenticated_userid"] = '{"user" : "rama", "email" : "rama@ayodhya.com", "nbf" : ' .. nbf .. ', "iss" : "OverWrittenClaim"}',
                  ["Content-Type"] = "application/json"
  		}
  	  })
  	  assert.response(r).has.status(200)
          local token = assert.request(r).has.header("x-authenticated_userid")
          local jwt = assert(jwt_parser:new(token))
          assert.True(jwt:verify_signature(fixtures.rs256_public_key))
	  assert.True(jwt:verify_registered_claims({ "nbf" }))
	  assert.True(jwt.claims["iss"] == "OverWrittenClaim")
    end)
  end)

  describe("send header in invalid format", function()
    it("default/configured jwt claims added", function()
	  local nbf = ngx_time() - 10
  	  local r = assert( client:send{
  	  	method = "POST",
  	  	path = "/post",
  	  	body = {},
  	  	headers = {
                  host = "test1.com",
  	  	  ["x-authenticated_userid"] = '{"user" : "rama", "email" : ""rama@ayodhya.com"}',
                  ["Content-Type"] = "application/json"
  		}
  	  })
  	  assert.response(r).has.status(200)
          local token = assert.request(r).has.header("x-authenticated_userid")
          local jwt = assert(jwt_parser:new(token))
          assert.True(jwt:verify_signature(fixtures.rs256_public_key))
	  assert.True(jwt.claims["iss"] == "tester")
    end)
  end)
end)
