module SpreeAtlassianTax
  class CreateTaxAdjustmentsService < SpreeAtlassianTax::Base
    include SpreeAtlassianTax::TaxAdjustmentLabelHelper

    def call(order:) # rubocop:disable Metrics/AbcSize
      return failure(::Spree.t('spree_atlassian_tax.create_tax_adjustments.order_canceled')) if order.canceled?

      order.all_adjustments.tax.destroy_all

      return failure(::Spree.t('spree_atlassian_tax.create_tax_adjustments.tax_calculation_unnecessary')) unless order.atlassian_tax_calculation_required?

      transaction_cache_key = SpreeAtlassianTax::GenerateTransactionCacheKeyService.call(order: order).value

      atlassian_response       = Rails.cache.fetch(transaction_cache_key, expires_in: 5.minutes) do
        send_transaction_to_atlassian(order)
      end

      return failure(build_error_message_from_response(atlassian_response.value)) if atlassian_failed_response?(atlassian_response)

      process_atlassian_items(order, atlassian_response.value['lines'])

      success(true)
    end

    private

    def send_transaction_to_atlassian(order)
      if order.atlassian_sales_invoice_transaction.present?
        SpreeAtlassianTax::Transactions::AdjustService.call(
          order:                  order,
          adjustment_reason:      SpreeAtlassianTax::Transaction::DEFAULT_ADJUSTMENT_REASON,
          adjustment_description: ::Spree.t('spree_atlassian_tax.create_tax_adjustments.adjustment_description')
        )
      else
        SpreeAtlassianTax::Transactions::CreateService.call(order: order)
      end
    end

    def atlassian_failed_response?(atlassian_response)
      atlassian_response.failure? || atlassian_response.value['totalTax'].zero?
    end

    def process_atlassian_items(order, atlassian_items)
      atlassian_items.each { |atlassian_item| process_atlassian_item(order, atlassian_item) }
    end

    def process_atlassian_item(order, atlassian_item)
      tax_amount = atlassian_item['taxCalculated'] + 10 # TODO: Fix, just for testing until the endpoint bug get fixed

      return if tax_amount.zero?

      item_suffix = atlassian_item['lineNumber'].slice(0..2)
      item_id     = atlassian_item['lineNumber'].slice(3..-1)
      item        = find_item(order, item_id, item_suffix)

      # Spree allows to setup shipping methods without tax category and
      # in that case it doesn't make sense to collect any tax,
      # especially because of validation that requires presence of tax category
      return if item.tax_category.nil?

      tax_rate = find_or_create_tax_rate(item, atlassian_item)

      store_pre_tax_amount(item, tax_rate, tax_amount)

      create_tax_adjustment(item, tax_rate, tax_amount)
    end

    def find_item(order, uuid, suffix)
      case suffix
      when 'LI-'
        order.line_items.find_by(atlassian_uuid: uuid)
      when 'FR-'
        order.shipments.find_by(atlassian_uuid: uuid)
      end
    end

    def find_or_create_tax_rate(item, atlassian_item)
      ::Spree::TaxRate.find_or_create_by!(
        name:               tax_rate_name,
        amount:             sum_rates_from_details(atlassian_item),
        zone:               item.tax_zone&.reload,
        tax_category:       item.tax_category,
        show_rate_in_label: false,
        included_in_price:  item.included_in_price
      ) do |tax_rate|
        tax_rate.calculator = SpreeAtlassianTax::Calculator::atlassianTransactionCalculator.new
      end
    end

    def tax_rate_name
      ENV.fetch('atlassian_TAX_RATE_NAME', 'atlassian Official Tax Rate')
    end

    def create_tax_adjustment(item, source, amount)
      item.adjustments.create!(
        source:   source,
        amount:   amount,
        included: item.included_in_price,
        label:    tax_adjustment_label(item, source.amount),
        order:    item.order
      )
    end

    def store_pre_tax_amount(item, tax_rate, tax_amount)
      pre_tax_amount = case item.class.name.demodulize
                       when 'LineItem' then item.discounted_amount
                       when 'Shipment' then item.discounted_cost
                       end

      pre_tax_amount -= tax_amount if tax_rate.included_in_price?

      item.update_column(:pre_tax_amount, pre_tax_amount)
    end

    def sum_rates_from_details(atlassian_item)
      atlassian_item['details']
        .sum { |detail_entry| detail_entry['rate'] }
        .round(6)
    end

    def build_error_message_from_response(atlassian_response)
      return ::Spree.t('spree_atlassian_tax.create_tax_adjustments.tax_calculation_failed') unless error_present?(atlassian_response)

      atlassian_response['error']['details'].map do |error_detail_entry|
        "#{error_detail_entry['number']} - #{error_detail_entry['message']} - #{error_detail_entry['description']}."
      end.join(' ')
    end

    def error_present?(atlassian_response)
      atlassian_response && atlassian_response['error'].present?
    end
  end
end
