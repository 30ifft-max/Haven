class AddClassificationToTransfers < ActiveRecord::Migration[7.2]
  def change
    add_column :transfers, :classification, :string
  end
end
