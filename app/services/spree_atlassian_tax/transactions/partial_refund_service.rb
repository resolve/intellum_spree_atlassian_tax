module SpreeAtlassianTax
  module Transactions
    class PartialRefundService < SpreeAtlassianTax::Base
      def call(order:, transaction_code:, refund_items:)
        response = send_request(order, transaction_code, refund_items)

        request_result(response, order) do
          unless response.body['id'].to_i.zero?
            create_transaction!(
              code:             response.body['code'],
              order:            order,
              transaction_type: SpreeAtlassianTax::Transaction::RETURN_INVOICE
            )
          end
        end
      end

      private

      def send_request(order, transaction_code, refund_items)
        refund_transaction_model = SpreeAtlassianTax::Transactions::PartialRefundPresenter.new(
          order:            order,
          refund_items:     refund_items,
          transaction_code: transaction_code
        ).to_json

        logger.info(refund_transaction_model)

        client.create_transaction(refund_transaction_model)
      end
    end
  end
end
