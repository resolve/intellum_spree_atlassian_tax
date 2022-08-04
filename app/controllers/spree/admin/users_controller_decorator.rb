module Spree
  module Admin
    module UsersControllerDecorator
      def self.prepended(base)
        base.before_action :load_use_codes, only: :atlassian_information
      end

      def atlassian_information
        if request.put? && @user.update_attributes(user_params)
          flash.now[:success] = Spree.t(:account_updated)
        end

        render :atlassian_information
      end

      private

      def load_use_codes
        return if request.put?

        @use_codes = SpreeAtlassianTax::EntityUseCode.all.map { |use_code| ["#{use_code.code} - #{use_code.name}", use_code.id] }
      end
    end
  end
end

::Spree::Admin::UsersController.prepend(Spree::Admin::UsersControllerDecorator)
