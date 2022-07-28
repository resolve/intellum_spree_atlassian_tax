require 'faraday_middleware'

module AtlassianTax
  class Client
    Dir[File.expand_path('client/*.rb', __FILE__)].each{|f| require f}

    include AtlassianTax::Api::Request
    include AtlassianTax::Api::Addresses
    include AtlassianTax::Api::Transactions
    include AtlassianTax::Api::Definitions
  end
end
