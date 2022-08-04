module SpreeAtlassianTax
  module HasUuid
    ATLASSIAN_CODES = {
      'LineItem' => 'LI',
      'Shipment' => 'FR'
    }.freeze

    def self.included(base)
      base.before_create :generate_uuid
    end

    def atlassian_number
      "#{ATLASSIAN_CODES[self.class.name.demodulize]}-#{atlassian_uuid}"
    end

    private

    def generate_uuid
      self.avatax_uuid = SecureRandom.uuid if atlassian_uuid.blank?
    end
  end
end
