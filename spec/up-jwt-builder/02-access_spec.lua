local helpers = require "spec.helpers"
local fixtures = require "spec.up-jwt-builder.fixtures"

local function isjwt(jwt)
  local res = 0
  if jwt then
    for w in jwt:gmatch'.' do
      res = res + 1
    end
  end
  return res ~= 0
end

describe("Upstream Jwt Builder (access)", function()
  local client

  setup(function()
  	helpers.run_migrations()
  	local api1 = assert(helpers.dao.apis:insert { name = "api-1", hosts = { "test1.com" }, upstream_url = helpers.mock_upstream_url})

  	assert(helpers.dao.plugins:insert{
  		api_id = api1.id,
  		name = "up-jwt-builder",
  		config = {
  		key = fixtures.rsa256_private_key,
  		alg = "RS256",
  		headers = {"x-powered-by"}
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
  		 ["x-powered-by"] = "user=rama,email=rama@ayodhya.com",
                 ["Content-Type"] = "application/json"
  		}
  	  })
  	  assert.response(r).has.status(200)
      	  assert.response(r).has.header("x-powered-by")
	  assert.truthy(isjwt(r.headers["x-powered-by"]))
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
  	  	  ["x-powered-by"] = '{"user" : "rama", "email" : "rama@ayodhya.com"}',
                  ["Content-Type"] = "application/json"
  		}
  	  })
  	  assert.response(r).has.status(200)
      	  assert.response(r).has.header("x-powered-by")
	  assert.truthy(isjwt(r.headers["x-powered-by"]))
  	end)
  end)
end)
