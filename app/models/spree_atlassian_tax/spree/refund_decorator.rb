module SpreeAtlassianTax
  module Spree
    module RefundDecorator
      def self.prepended(base)
        base.after_create :refund_in_atlassian

        base.delegate :order,                    to: :payment
        base.delegate :inventory_units, :number, to: :order, prefix: true
      end

      private

      def refund_in_atlassian
        return unless SpreeAtlassianTax::Config.enabled && SpreeAtlassianTax::Config.commit_transaction_enabled

        SpreeAtlassianTax::Transactions::RefundService.call(refundable: self)
      end
    end
  end
end

::Spree::Refund.prepend ::SpreeAtlassianTax::Spree::RefundDecorator
