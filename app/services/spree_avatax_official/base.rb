module SpreeAvataxOfficial
  class Base
    prepend ::Spree::ServiceModule::Base

    APP_NAME           = 'a0o0b000005HsXPAA0'.freeze
    APP_VERSION        = 'Spree by Spark'.freeze
    SUCCESS_STATUSES   = [200, 201].freeze
    CONNECTION_OPTIONS = ::AvaTax::Configuration::DEFAULT_CONNECTION_OPTIONS.merge(
      request: {
        timeout:      SpreeAvataxOfficial::Config.read_timeout,
        open_timeout: SpreeAvataxOfficial::Config.open_timeout
      }
    ).freeze

    private

    # def client
    #   AvaTax::Client.new(
    #     app_name:           APP_NAME,
    #     app_version:        APP_VERSION,
    #     connection_options: CONNECTION_OPTIONS,
    #     logger:             true,
    #     faraday_response:   true,
    #     endpoint:           SpreeAvataxOfficial::Config.endpoint,
    #     username:           SpreeAvataxOfficial::Config.account_number,
    #     password:           SpreeAvataxOfficial::Config.license_key
    #   )
    # end

    def client
      Faraday.new(SpreeAvataxOfficial::Config.endpoint) do |con|
        con.request :basic_auth,
                    SpreeAvataxOfficial::Config.account_number,
                    SpreeAvataxOfficial::Config.license_key
        con.headers['sourceSystem'] = 'CCP'
        con.headers['Content-Type'] = 'application/json'
        con.adapter :net_http
        con.request :retry
        con.response :json, content_type: /\bjson$/
      end
    end

    def company_code(order)
      order.store&.avatax_company_code || SpreeAvataxOfficial::Config.company_code
    end

    def request_result(response, object = nil)
      status        = response.try(:status)
      response_body = status ? response.body : response

      # binding.pry

      if request_error?(status, response_body)
        logger.error(object, response)

        failure(response_body)
      else
        yield if block_given?

        logger.info(response, object)

        success(response_body)
      end
    end

    def request_error?(status, response_body)
      response_body['error'].present? || !status.in?(SUCCESS_STATUSES)
    end

    def refund_transaction_code(order_number, refundable_id)
      "#{order_number}-#{refundable_id}"
    end

    def create_transaction!(order:, code: nil, transaction_type: nil)
      SpreeAvataxOfficial::Transaction.create!(
        code:             code || order.number,
        order:            order,
        transaction_type: transaction_type || SpreeAvataxOfficial::Transaction::SALES_INVOICE
      )
    end

    def logger
      @logger ||= SpreeAvataxOfficial::AvataxLog.new
    end
  end
end
