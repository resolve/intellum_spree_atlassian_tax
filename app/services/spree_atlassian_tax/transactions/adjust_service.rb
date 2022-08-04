module SpreeAtlassianTax
  module Transactions
    class AdjustService < SpreeAtlassianTax::Base
      def call(order:, adjustment_reason:, adjustment_description: '', options: {})
        response = send_request(order, adjustment_reason, adjustment_description, options)

        request_result(response, order) do
          if order.atlassian_sales_invoice_transaction.nil?
            create_transaction!(
              order: order
            )
          end
        end
      end

      private

      def send_request(order, adjustment_reason, adjustment_description, options) # rubocop:disable Metrics/MethodLength
        adjust_transaction_model = SpreeAtlassianTax::Transactions::AdjustPresenter.new(
          order:                  order,
          adjustment_reason:      adjustment_reason,
          adjustment_description: adjustment_description
        ).to_json

        logger.info(adjust_transaction_model)

        client.adjust_transaction(
          company_code(order),
          order.number,
          adjust_transaction_model,
          options
        )
      end
    end
  end
end
