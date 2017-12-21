local jwt_encoder = require "kong.plugins.up-jwt-builder.jwt_encoder"
local fixtures = require "spec.up-jwt-builder.fixtures"
local helpers = require "spec.helpers"
local u = helpers.unindent

describe("Encoding", function()
	    it("should encode using RS512", function()
      local token = jwt_encoder.encode({
        sub   = "shiva2991",
        name  = "Rahogata",
        admin = true,
      }, fixtures.rs512_private_key, "RS512")

      if helpers.openresty_ver_num < 11123 then
        assert.equal(u([[
          eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJhZG1pbiI6dHJ1ZSwibmFtZSI6Ikpv
          aG4gRG9lIiwic3ViIjoiMTIzNDU2Nzg5MCJ9.VhoFYud-lrxtkbkfMl0Wkr4fERsDNjGf
          vHc2hFEecjLqSJ65_cydJiU011QqAmlMM8oIRCnoGKvA63XeE7M6qPsNkJ_vHMoqO-Hg3
          ajx1RaWmVaHyeTCkkyStNvh88phVSH5EB5wIYjukHErRXLCTL9UhE0Z60fNzLeEZ5yJZS
          -rhOK3fa0QSVoTD2QKVITYBcX_xt6NzHzTTx_3kQ1KlcuueNlOLmCYx_6tissUvMY91Kj
          cZfs3z9tYREu5paFx0pSiPvgNBvrWQfbm3irr-1YcBH7wJuIinPDrERVohK1v37t8fDnS
          qhi1tWUati7Mynkb3JrpCeF3IyReSvkhQA
        ]], true), token)
      else
        assert.equal(u([[
          eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiUmFob2dhdGEiLCJhZG1p
          biI6dHJ1ZSwic3ViIjoic2hpdmEyOTkxIn0.RUoOxw5wR7v2W7uLSMQrJ4Im0zCZKythL
          7Z9Yjt7ijZrePJDs9UuVN6gNqJTl50RjW6xNGSfCatEhCKjAWVTAAa5CCzXkisX0Ux1Tt
          J7asepprViTB8duSyLOlKInnmlH3r_xaaaJ1rQNqLtib_ZHfpnG_D4Lik2uVmsAWFQQBx
          r9EHyHlPldn_cNwU_wDIc1MVqoXCVEmHy6ZSbtelUkvv82zcfVpO7z6LMCRb-xlU-_ify
          WjlVIsChdMrDvNEV0BeK0eIyRatOLjv5BwI7L-nnN3VkwEISo0ap3cQsGWAVATBtTAwaP
          faX6qyhR7FO2oT3pVrWO3G0BiIe9TB25A
        ]], true), token)
      end
    end)
end)