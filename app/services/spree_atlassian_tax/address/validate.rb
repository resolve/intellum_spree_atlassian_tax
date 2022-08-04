module SpreeAtlassianTax
  module Address
    class Validate < SpreeAtlassianTax::Base
      def call(address:)
        response = send_request(address)

        return failure(response) if errors?(response)

        success(response)
      end

      private

      def errors?(response)
        response.body['messages'] || response.body['error']
      end

      def send_request(address)
        ship_to_address_model = SpreeAtlassianTax::ShipToAddressPresenter.new(
          address: address
        ).to_json

        client.resolve_address(ship_to_address_model)
      end
    end
  end
end
