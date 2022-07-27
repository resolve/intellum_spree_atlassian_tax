module SpreeAvataxOfficial
  module Transactions
    class CreateService < SpreeAvataxOfficial::Base
      def call(order:, options: {}) # rubocop:disable Metrics/MethodLength
        return failure(false) unless can_send_order_to_avatax?(order)

        transaction_type = choose_transaction_type(order)
        response         = send_request(order, transaction_type, options)

        # binding.pry
        request_result(response, order) do
          if order.completed? && response.body['id'].to_i.positive?
            create_transaction!(
              order:            order,
              transaction_type: transaction_type
            )
          end
        end
      end

      private

      def can_send_order_to_avatax?(order)
        # We need to ensure that order would not be commited multiple of times
        order.avatax_tax_calculation_required? && order.avatax_sales_invoice_transaction.blank?
      end

      def choose_transaction_type(order)
        if order.completed?
          SpreeAvataxOfficial::Transaction::SALES_INVOICE
        else
          SpreeAvataxOfficial::Transaction::SALES_ORDER
        end
      end

      # def send_request(order, transaction_type, options)
      #   create_transaction_model = SpreeAvataxOfficial::Transactions::CreatePresenter.new(
      #     order:            order,
      #     transaction_type: transaction_type
      #   ).to_json
      #
      #   logger.info(create_transaction_model)
      #
      #   client.create_transaction(create_transaction_model, options)
      # end

      def send_request(order, transaction_type, options)
        # binding.pry
        client.post do |req|
          req.url '/finsys/api/1/avalara/transactions/create'
          req.body = formated_order(order, transaction_type).to_json
        end
      end


      def format_items(line_item)
        return unless line_item.present?

        {}.tap do |item|
          item['number']      = line_item.id.to_s
          item['quantity']    = line_item.quantity
          item['amount']      = line_item.price.to_f
          item['taxCode']     = line_item.tax_category.try :tax_code
          item['itemCode']    = line_item.sku
          item['description'] = line_item.name
          item['discounted']  = !line_item.adjustments.promotion.any?
        end
      end

      def formated_address(address)
        return '' unless address.present?

        {}.tap do |add|
          add[:line1]       = address.address1
          add[:city]        = address.city
          add[:country]     = address.country_iso
          add[:region]      = address.state_abbr
          add[:postalCode]  = address.zipcode
        end
      end

      def formated_line_items(line_items)
        line_items.map { |item| format_items(item) }
      end

      def formated_order(order, transaction_type)
        {}.tap do |req|
          req[:lines]             = formated_line_items(order.line_items)
          req[:purchaseOrderNo]   = order.number
          req[:customerCode]      = order.user_id || order.email
          req[:currencyCode]      = order.currency
          req[:date]              = order.created_at.strftime('%Y-%m-%d')
          req[:email]             = order.email
          req[:type]              = transaction_type
          req[:description]       = "Transaction Number: #{order.number}"
          req[:discount]          = order.adjustments.promotion.sum(&:amount)
          req[:addresses]         = {
            shipFrom: {
              line1:      '21092 Beach Blvd',
              city:       'Huntington Beach',
              region:     'CA',
              country:    'US',
              postalCode: '92648'
            },
            shipTo: formated_address(order.billing_address)
          }
        end
      end
    end
  end
end
