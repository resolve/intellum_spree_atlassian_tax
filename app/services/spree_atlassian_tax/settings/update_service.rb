module SpreeAtlassianTax
  module Settings
    class UpdateService < SpreeAtlassianTax::Base
      def call(params:)
        update_settings(params)
      end

      private

      def update_settings(params)
        update_address_settings(params[:ship_from])

        SpreeAtlassianTax::Config.account_number             = params[:account_number] if params.key?(:account_number)
        SpreeAtlassianTax::Config.license_key                = params[:license_key] if params.key?(:license_key)
        SpreeAtlassianTax::Config.company_code               = params[:company_code] if params.key?(:company_code)
        SpreeAtlassianTax::Config.endpoint                   = params[:endpoint] if params.key?(:endpoint)
        SpreeAtlassianTax::Config.address_validation_enabled = params[:address_validation_enabled] if params.key?(:address_validation_enabled)
        SpreeAtlassianTax::Config.commit_transaction_enabled = params[:commit_transaction_enabled] if params.key?(:commit_transaction_enabled)
        SpreeAtlassianTax::Config.enabled                    = params[:enabled] if params.key?(:enabled)
      end

      def update_address_settings(ship_from_params)
        return unless ship_from_params

        SpreeAtlassianTax::Config.ship_from_address = {
            line1:      ship_from_params[:line1],
            line2:      ship_from_params[:line2],
            city:       ship_from_params[:city],
            region:     ship_from_params[:region],
            country:    ship_from_params[:country],
            postalCode: ship_from_params[:postal_code]
        }
      end
    end
  end
end
