require 'faraday_middleware'

module AtlassianTax::Api::Connection
  private

  def connection
    Faraday.new(::SpreeAvataxOfficial::Config.endpoint) do |con|
      con.request :basic_auth,
                  ::SpreeAvataxOfficial::Config.account_number,
                  ::SpreeAvataxOfficial::Config.license_key
      con.headers['sourceSystem'] = 'CCP'
      con.headers['Content-Type'] = 'application/json'
      con.adapter :net_http
      con.request :retry
      con.response :json, content_type: /\bjson$/
    end
  end
end
