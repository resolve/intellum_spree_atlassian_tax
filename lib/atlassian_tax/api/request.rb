module AtlassianTax::Api
  module Request
    include ::SpreeAvataxOfficial::HttpHelper
    include AtlassianTax::Api::Connection

    def get(path, options={}, apiversion="", headers=Hash.new)
      request(:get, path, nil, options)
    end

    def post(path, model, options={}, apiversion="", headers=Hash.new)
      request(:post, path, model, options)
    end

    def put(path, model, options={}, apiversion="", headers=Hash.new)
      request(:put, path, model, options)
    end

    def delete(path, options={}, apiversion="", headers=Hash.new)
      request(:delete, path, nil, options)
    end

    def request(method, path, model, options = {})
      max_retries                  ||= ::SpreeAvataxOfficial::Config.max_retries
      uri_encoded_path               = URI.parse(path).to_s
      response                       = connection.send(method) do |request|
        request.options['timeout'] ||= 1_200
        case method
        when :get, :delete
          request.url("#{uri_encoded_path}?#{URI.encode_www_form(options)}")
        when :post, :put
          request.url("#{uri_encoded_path}?#{URI.encode_www_form(options)}")
          request.headers['Content-Type'] = 'application/json'
          request.body                    = model.to_json unless model.empty?
        end
      end

      response.body
    rescue *::SpreeAvataxOfficial::HttpHelper::CONNECTION_ERRORS => e
      retry unless (max_retries -= 1).zero?

      mock_error_response(e) # SpreeAvataxOfficial::HttpHelper method
    end
  end
end
