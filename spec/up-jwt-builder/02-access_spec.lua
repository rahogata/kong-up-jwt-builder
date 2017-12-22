local helpers = require "spec.helpers"
local fixtures = require "spec.up-jwt-builder.fixtures"

describe("Upstream Jwt Builder (access)", function()
  local client

  setup(function()
  	helpers.run_migrations()
  	local api1 = assert(helpers.dao.apis:insert { name = "api-1", uris = { "/oauth2/token" }, upstream_url = "http://127.0.0.1/"})

  	assert(helpers.dao.plugins:insert{
  		api_id = api1.id,
  		name = "up-jwt-builder",
  		config = {
  		key = fixtures.rsa256_private_key,
  		alg = "RS256",
  		headers = {"x-authenticated_userid"}
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
  		path = "/oauth2/token",
  		body = "",
  		headers = {
  		 ["x-authenticated_userid"] = "user=rama,email=rama@ayodhya.com"
  		}
  	  })
  	  assert.response(r).has.status(200)
  	  print(r.headers["x-authenticated_userid"])
  	  assert.truthy(r.headers["x-authenticated_userid"])
  	end)
  end)

  describe("send header as json", function()
  	it("replace json with jwt token", function()
  	  local r = assert( client:send{
  	  	method = "POST",
  	  	path = "/oauth2/token",
  	  	body = "",
  	  	headers = {
  	  	  ["x-authenticated_userid"] = '{"user" : "rama", "email" : "rama@ayodhya.com"}'
  		}
  	  })
  	  assert.response(r).has.status(200)
  	  assert.truthy(r.headers["x-authenticated_userid"])
  	end)
  end)
end)