module SpreeAtlassianTax
  class Base
    prepend ::Spree::ServiceModule::Base

    APP_NAME           = 'a0o0b000005HsXPAA0'.freeze
    APP_VERSION        = 'Spree by Spark'.freeze
    SUCCESS_STATUSES   = [200, 201].freeze
    CONNECTION_OPTIONS = ::AvaTax::Configuration::DEFAULT_CONNECTION_OPTIONS.merge(
      request: {
        timeout:      SpreeAtlassianTax::Config.read_timeout,
        open_timeout: SpreeAtlassianTax::Config.open_timeout
      }
    ).freeze

    private

    def client
      AtlassianTax::Client.new
    end

    def company_code(order)
      order.store&.atlassian_company_code || SpreeAtlassianTax::Config.company_code
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
      SpreeAtlassianTax::Transaction.create!(
        code:             code || order.number,
        order:            order,
        transaction_type: transaction_type || SpreeAtlassianTax::Transaction::SALES_INVOICE
      )
    end

    def logger
      @logger ||= SpreeAtlassianTax::AtlassianLog.new
    end
  end
end
