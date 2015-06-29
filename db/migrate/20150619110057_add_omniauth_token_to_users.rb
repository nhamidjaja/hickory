class AddOmniauthTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :omniauth_token, :string
  end
end
