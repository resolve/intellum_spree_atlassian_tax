class AddAtlassianCompanyCodeToSpreeStores < SpreeExtension::Migration[4.2]
  def change
    return unless table_exists? :spree_stores
    return if column_exists? :spree_stores, :atlassian_company_code

    add_column :spree_stores, :atlassian_company_code, :string
  end
end
