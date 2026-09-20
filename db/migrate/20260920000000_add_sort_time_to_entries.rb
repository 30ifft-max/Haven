class AddSortTimeToEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :entries, :sort_time, :time, null: false, default: "00:00:00"
    add_index :entries, [ :date, :sort_time, :created_at, :id ], name: "index_entries_on_display_order"
  end
end
