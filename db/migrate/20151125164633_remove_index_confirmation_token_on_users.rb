class RemoveIndexConfirmationTokenOnUsers < ActiveRecord::Migration
  def up
    remove_index :users, :confirmation_token
  end

  def down
    add_index :users, :confirmation_token,   unique: true
  end
end
