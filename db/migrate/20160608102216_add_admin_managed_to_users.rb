class AddAdminManagedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin_managed, :boolean, null: false, default: false
  end
end
