class CreateFeaturedUsers < ActiveRecord::Migration
  def change
    create_table :featured_users, id: false do |t|
      t.uuid :user_id, primary_key: true

      t.timestamps null: false
    end
  end
end
