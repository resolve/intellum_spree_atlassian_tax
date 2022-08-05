require 'faraday_middleware'

module AtlassianTax::Api::Connection
  private

  def connection
    Faraday.new(::SpreeAtlassianTax::Config.endpoint) do |con|
      con.request :basic_auth,
                  ::SpreeAtlassianTax::Config.account_number,
                  ::SpreeAtlassianTax::Config.license_key
      con.headers['sourceSystem'] = 'CCP'
      con.headers['Content-Type'] = 'application/json'
      con.adapter :net_http
      con.request :retry
      con.response :json, content_type: /\bjson$/
    end
  end
end
