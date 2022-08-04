class CreateSpreeAtlassianOfficialTransactions < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_atlassian_transactions do |t|
      t.references :order,             null: false, index: true
      t.string     :transaction_type,  null: false, index: true
      t.string     :code,              null: false, index: { unique: true }
      t.timestamps
    end
  end
end
