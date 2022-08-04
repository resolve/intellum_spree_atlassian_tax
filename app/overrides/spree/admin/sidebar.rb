Deface::Override.new(
  virtual_path: 'spree/admin/users/_sidebar',
  name: 'add atlassian information link',
  insert_bottom: '[data-hook="admin_user_tab_options"]',
) do
  <<~HTML
    <li>
      <%= link_to_with_icon 'money',
        Spree.t('spree_atlassian_tax.information_url'),
        atlassian_information_admin_user_path(@user),
        class: "nav-link" %>
    </li>
  HTML
end
