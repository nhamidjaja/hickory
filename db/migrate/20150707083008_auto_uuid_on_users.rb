class AutoUuidOnUsers < ActiveRecord::Migration
  def up
    change_column :users, :id, :uuid, default: 'uuid_generate_v4()'
  end

  def down
    change_column :users, :id, :uuid
  end
end
