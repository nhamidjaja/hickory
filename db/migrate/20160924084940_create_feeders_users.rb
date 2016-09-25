class CreateFeedersUsers < ActiveRecord::Migration
  def change
    create_table :feeders_users, id: false do |t|
      t.uuid :feeder_id
      t.uuid :user_id
    end

    add_index :feeders_users, :user_id
    add_index :feeders_users, :feeder_id

    add_foreign_key :feeders_users, :users
  end
end
