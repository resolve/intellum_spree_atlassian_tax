module SpreeAtlassianTax
  module Transactions
    class GetByCodeService < SpreeAtlassianTax::Base
      def call(order:, type: 'SalesInvoice', code: nil)
        code ||= transaction_code(order, type)

        return failure(::Spree.t('spree_atlassian_tax.get_by_code_service.missing_code')) if code.nil?

        request_result(get_by_code(code, order), order)
      end

      private

      def get_by_code(code, order)
        logger.info(code)

        client.get_transaction_by_code(
          company_code(order),
          code
        )
      end

      def transaction_code(order, type)
        transaction = order
                      .atlassian_transactions
                      .find_by(transaction_type: type)

        transaction.try(:code) || order.number
      end
    end
  end
end
