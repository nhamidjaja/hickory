class AddIconUrlToFeeder < ActiveRecord::Migration
  def change
    add_column :feeders, :icon_url, :string
  end
end
