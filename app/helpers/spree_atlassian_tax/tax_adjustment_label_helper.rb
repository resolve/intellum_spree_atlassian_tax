module SpreeAtlassianTax
  module TaxAdjustmentLabelHelper
    include ActionView::Helpers::NumberHelper

    STRIP_INSIGNIFICANT_ZEROS  = true
    PRECISION_OF_PERCENT_VALUE = 10

    def tax_adjustment_label(item, rate)
      item_class = item.class.name.demodulize.underscore

      format_adjustment_label(
        ::Spree.t("spree_atlassian_tax.create_tax_adjustments.#{item_class}_tax_adjustment_default_label", included_label: included_label(item)),
        rate
      )
    end

    def included_label(item)
      item.included_in_price ? 'Included ' : ''
    end

    def format_adjustment_label(adjustment_default_label, rate)
      rate_in_percents = number_to_percentage(
        rate * 100.0,
        precision:                 PRECISION_OF_PERCENT_VALUE,
        strip_insignificant_zeros: STRIP_INSIGNIFICANT_ZEROS
      )
      SpreeAtlassianTax::Config.show_rate_in_label ? "#{adjustment_default_label} (#{rate_in_percents})" : adjustment_default_label
    end
  end
end
