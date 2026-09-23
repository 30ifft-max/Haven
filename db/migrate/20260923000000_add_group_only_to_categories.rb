class AddGroupOnlyToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :group_only, :boolean, default: false, null: false
  end
end
