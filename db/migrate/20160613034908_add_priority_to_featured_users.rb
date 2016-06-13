class AddPriorityToFeaturedUsers < ActiveRecord::Migration
  def change
    add_column :featured_users, :priority, :integer, null: false, default: 9

    add_foreign_key :featured_users, :users
  end
end
