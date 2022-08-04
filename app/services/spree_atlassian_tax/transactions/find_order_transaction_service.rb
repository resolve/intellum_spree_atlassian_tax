module SpreeAtlassianTax
  module Transactions
    class FindOrderTransactionService < SpreeAtlassianTax::Base
      def call(order:)
        return success(true)  if order.atlassian_sales_invoice_transaction.present?
        return failure(false) if get_transaction(order).failure?

        order.create_atlassian_sales_invoice_transaction(code: order.number)

        # ensure taxable items have atlassian_uuid
        order.taxable_items.each { |item| item.update(atlassian_uuid: SecureRandom.uuid) }

        success(true)
      end

      private

      def get_transaction(order)
        SpreeAtlassianTax::Transactions::GetByCodeService.call(order: order)
      end
    end
  end
end
