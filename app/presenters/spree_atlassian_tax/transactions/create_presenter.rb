module SpreeAtlassianTax
  module Transactions
    class CreatePresenter
      def initialize(order:, transaction_type:, transaction_code: order.number)
        @order            = order
        @transaction_type = transaction_type
        @transaction_code = transaction_code
      end

      # Based on: https://developer.avalara.com/api-reference/avatax/rest/v2/models/CreateTransactionModel/
      def to_json # rubocop:disable Metrics/MethodLength
        {
          type:            transaction_type,
          code:            transaction_code,
          referenceCode:   order.number,
          companyCode:     company_code,
          date:            formatted_date(order_date),
          customerCode:    customer_code,
          addresses:       addresses_payload,
          lines:           items_payload,
          commit:          completed?(order),
          discount:        order.atlassian_discount_amount.to_f,
          currencyCode:    currency_code,
          purchaseOrderNo: order.number,
          entityUseCode:   entity_use_code || ''
        }
      end

      delegate :atlassian_ship_from_address, :user, to: :order

      private

      attr_reader :order, :transaction_type, :transaction_code

      def company_code
        order.store.try(:atlassian_company_code) || SpreeAtlassianTax::Config.company_code
      end

      def entity_use_code
        user.try(:atlassian_entity_use_code).try(:code)
      end

      def formatted_date(date)
        date.strftime('%Y-%m-%d')
      end

      def order_date
        order.completed_at || order.updated_at
      end

      def customer_code
        user.try(:email) || order.email
      end

      def ship_from_payload
        SpreeAtlassianTax::AddressPresenter.new(address: atlassian_ship_from_address, address_type: 'ShipFrom').to_json
      end

      def ship_to_payload
        SpreeAtlassianTax::AddressPresenter.new(address: order.tax_address, address_type: 'ShipTo').to_json
      end

      def addresses_payload
        ship_from_payload.merge(ship_to_payload)
      end

      def items_payload
        order.taxable_items.map { |item| SpreeAtlassianTax::ItemPresenter.new(item: item).to_json }
      end

      def completed?(order)
        order.completed_at.present?
      end

      def currency_code
        order.currency || ::Spree::Config[:currency]
      end
    end
  end
end
