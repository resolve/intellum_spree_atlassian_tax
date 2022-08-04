Deface::Override.new(
  virtual_path:  'spree/admin/shared/sub_menu/_configuration',
  name:          'add_altassian_admin_menu_links',
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']"
) do
  <<~HTML
    <%= configurations_sidebar_menu_item(Spree.t('spree_atlassian_tax.settings'), edit_admin_atlassian_settings_path) %>
    <%= configurations_sidebar_menu_item(Spree.t('spree_atlassian_tax.atlassian_entity_use_code'), admin_atlassian_entity_use_codes_path) %>
  HTML
end
