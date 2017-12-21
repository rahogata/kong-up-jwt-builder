local helpers = require "spec.helpers"
local fixtures = require "spec.up-jwt-builder.fixtures"

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
  		headers = {"x-authenticated_userid"}
  		}
  	})
  	assert(helpers.start_kong({
  	  trusted_ips       = "0.0.0.0/0, ::/0",
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

  describe("send header", function()
  	it("replace header to jwt token", function()
  	  local r = assert( client:send{
  		method = "POST",
  		path = "/oauth/token",
  		body = {},
  		headers = { ["x-authenticated_userid"] = "user=shiva2991,email=shiva20grk@gmail.com" }
  		})
  	  assert.response(r).has.status(200)
  	end)
  end)
end)