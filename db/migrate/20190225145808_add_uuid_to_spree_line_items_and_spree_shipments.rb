class AddUuidToSpreeLineItemsAndSpreeShipments < SpreeExtension::Migration[4.2]
  def change
    unless column_exists?(:spree_line_items, :atlassian_uuid)
      add_column :spree_line_items, :atlassian_uuid, :string
      add_index  :spree_line_items, :atlassian_uuid, unique: true
    end

    return if column_exists?(:spree_shipments, :atlassian_uuid)

    add_column :spree_shipments, :atlassian_uuid, :string
    add_index  :spree_shipments, :atlassian_uuid, unique: true
  end
end
