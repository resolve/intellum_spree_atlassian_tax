module SpreeAtlassianTax
  class EntityUseCode < ::Spree::Base
    self.table_name = 'spree_avatax_official_entity_use_codes' # Todo: remove after migration change
    with_options presence: true do
      validates :code, :name, uniqueness: true
    end
  end
end
