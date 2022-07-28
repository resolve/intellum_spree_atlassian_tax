module AtlassianTax::Api
  module Addresses
    def resolve_address(options={})
      path = '/finsys/api/1/avalara/addresses/resolve'
      get(path, options, "22.6.1")
    end

    def resolve_address_post(model)
      path = '/finsys/api/1/avalara/addresses/resolve'
      post(path, model, {}, "22.6.1")
    end
  end
end
