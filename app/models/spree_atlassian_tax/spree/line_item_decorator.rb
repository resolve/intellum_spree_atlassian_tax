module SpreeAtlassianTax
  module Spree
    module LineItemDecorator
      delegate :tax_zone, to: :order

      def self.prepended(base)
        base.include ::SpreeAtlassianTax::HasUuid
      end

      def included_in_price
        tax_zone.try(:included_in_price) || false
      end

      def update_tax_charge
        return super unless SpreeAtlassianTax::Config.enabled

        SpreeAtlassianTax::CreateTaxAdjustmentsService.call(order: order)
      end

      def atlassian_tax_code
        tax_category.try(:tax_code).presence || ::Spree::TaxCategory::DEFAULT_TAX_CODES['LineItem']
      end
    end
  end
end

::Spree::LineItem.prepend ::SpreeAtlassianTax::Spree::LineItemDecorator
