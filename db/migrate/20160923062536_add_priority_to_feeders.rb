class AddPriorityToFeeders < ActiveRecord::Migration
  def change
    add_column :feeders, :priority, :integer, null: false, default: 9

    add_index :feeders, :priority, order: { priority: :asc }
  end
end
