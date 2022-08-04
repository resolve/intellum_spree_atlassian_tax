module SpreeAtlassianTax
  module Transactions
    class FullRefundService < SpreeAtlassianTax::Base
      def call(order:, transaction_code:)
        create_refund(order, transaction_code).tap do |response|
          return request_result(response, order) do
            create_transaction!(
              code:             response.body['code'],
              order:            order,
              transaction_type: SpreeAtlassianTax::Transaction::RETURN_INVOICE
            )
          end
        end
      end

      private

      def create_refund(order, transaction_code)
        logger.info(refund_model(order, transaction_code))

        client.refund_transaction(
          company_code(order),
          order.number,
          refund_model(order, transaction_code)
        )
      end

      def refund_model(order, transaction_code)
        @refund_model ||= FullRefundPresenter.new(
          order:            order,
          transaction_code: transaction_code
        ).to_json
      end
    end
  end
end
