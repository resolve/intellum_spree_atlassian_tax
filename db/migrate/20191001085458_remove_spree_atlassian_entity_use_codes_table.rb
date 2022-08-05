class RemoveSpreeAtlassianEntityUseCodesTable < SpreeExtension::Migration[4.2]
  def change
    return unless table_exists?(:spree_atlassian_entity_use_codes)

    drop_table :spree_atlassian_entity_use_codes do |t|
      t.string :use_code, index: true
      t.string :use_code_description

      t.timestamps
    end
  end
end
