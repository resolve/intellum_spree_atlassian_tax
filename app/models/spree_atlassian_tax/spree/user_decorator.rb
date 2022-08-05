module SpreeAtlassianTax
  module Spree
    module UserDecorator
      def self.prepended(base)
        base.belongs_to :atlassian_entity_use_code, class_name: 'SpreeAtlassianTax::EntityUseCode'
      end
    end
  end
end

::Spree::User.prepend ::SpreeAtlassianTax::Spree::UserDecorator
