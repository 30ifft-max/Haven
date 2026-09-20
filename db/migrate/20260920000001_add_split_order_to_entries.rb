class AddSplitOrderToEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :entries, :split_order, :integer
    add_index :entries, [ :parent_entry_id, :split_order ], name: "index_entries_on_parent_and_split_order"
  end
end
