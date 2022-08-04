module SpreeAtlassianTax
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.register_update_hook :recalculate_atlassian_taxes

        base.has_many :atlassian_transactions, class_name: 'SpreeAtlassianTax::Transaction'

        base.has_one :atlassian_sales_invoice_transaction, -> { where(transaction_type: 'SalesInvoice') },
                     class_name: 'SpreeAtlassianTax::Transaction',
                     inverse_of: :order

        base.state_machine.before_transition to: :delivery, do: :validate_tax_address, if: :address_validation_enabled?
        base.state_machine.after_transition to: :canceled, do: :void_in_atlassian
        base.state_machine.after_transition to: :complete, do: :commit_in_atlassian
      end

      def taxable_items
        line_items.reload + shipments.reload
      end

      def atlassian_tax_calculation_required?
        tax_address&.persisted? && line_items.any?
      end

      def atlassian_discount_amount
        adjustments.promotion.eligible.sum(:amount).abs
      end

      def atlassian_ship_from_address
        SpreeAtlassianTax::Config.ship_from_address
      end

      def line_items_discounted_in_atlassian?
        adjustments.promotion.eligible.any?
      end

      def tax_address_symbol
        ::Spree::Config.tax_using_ship_address ? :ship_address : :bill_address
      end

      def create_tax_charge!
        return super unless SpreeAtlassianTax::Config.enabled

        SpreeAtlassianTax::CreateTaxAdjustmentsService.call(order: self)
      end

      def recalculate_atlassian_taxes
        binding.pry
        return unless SpreeAtlassianTax::Config.enabled

        SpreeAtlassianTax::CreateTaxAdjustmentsService.call(order: self)
        update_totals
        persist_totals
      end

      def validate_tax_address
        response = SpreeAtlassianTax::Address::Validate.call(
          address: tax_address
        )

        return if response.success?

        error_message = response.value.body['messages'].map { |message| message['summary'] }.join('. ')

        errors.add(:base, error_message)

        false
      end

      def address_validation_enabled?
        SpreeAtlassianTax::Config.address_validation_enabled
      end

      private

      def commit_in_atlassian
        return unless SpreeAtlassianTax::Config.enabled && SpreeAtlassianTax::Config.commit_transaction_enabled

        SpreeAtlassianTax::Transactions::CreateService.call(order: self)
      end

      def void_in_atlassian
        return unless SpreeAtlassianTax::Config.enabled

        SpreeAtlassianTax::Transactions::VoidService.call(order: self)
      end
    end
  end
end

::Spree::Order.prepend ::SpreeAtlassianTax::Spree::OrderDecorator
