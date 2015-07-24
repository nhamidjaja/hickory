class CreateUserFriends < ActiveRecord::Migration
  def up
    create_table :user_friends, id: false do |t|
      t.uuid :user_id
      t.string :provider
      t.string :uid

      t.timestamps null: false
    end
    execute "ALTER TABLE user_friends ADD PRIMARY KEY (user_id,provider,uid)"
    add_foreign_key :user_friends, :users
  end
  
  def down
    remove_foreign_key :user_friends, :users
    execute "ALTER TABLE user_friends DROP CONSTRAINT user_friends_pkey"
    drop_table :user_friends
  end
end
