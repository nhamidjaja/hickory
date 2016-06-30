class RemoveIdFromGcms < ActiveRecord::Migration
  def change
    remove_column :gcms, :id, :integer
  end
end
