module SpreeAtlassianTax
  class AddressPresenter
    def initialize(address:, address_type:)
      @address      = address
      @address_type = address_type
    end

    # Based on: https://developer.avalara.com/api-reference/avatax/rest/v2/models/AddressLocationInfo/
    def to_json
      {
        address_type => serialized_address
      }
    end

    private

    attr_reader :address, :address_type

    def serialized_address
      address_type == 'ShipFrom' ? ship_from_address : ship_to_address
    end

    def ship_to_address
      SpreeAtlassianTax::ShipToAddressPresenter.new(
        address: address
      ).to_json
    end

    # TODO: Remove this temporary fix and include the correct from shipping*
    def ship_from_address
      {
        line1:      '21092 Beach Blvd',
        line2:      nil,
        city:       'Huntington Beach',
        region:     'CA',
        country:    'US',
        postalCode: '92648'
      }
    end
  end
end
