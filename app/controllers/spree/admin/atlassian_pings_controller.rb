module Spree
  module Admin
    class AtlassianPingsController < Spree::Admin::BaseController
      respond_to :html

      def create
        response = SpreeAtlassianTax::Utilities::PingService.call
        if response.success? && response['value']['authenticated']
          flash[:success] = Spree.t('spree_atlassian_tax.connected_successful')
        elsif response.success? && !response['value']['authenticated']
          flash[:error] = Spree.t('spree_atlassian_tax.unauthorized')
        else
          flash[:error] = Spree.t('spree_atlassian_tax.connection_rejected')
        end
        redirect_to edit_admin_avatax_settings_path
      end
    end
  end
end
