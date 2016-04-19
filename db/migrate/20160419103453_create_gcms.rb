class CreateGcms < ActiveRecord::Migration
  def change
    create_table :gcms do |t|
      t.uuid :user_id, index: true, foreign_key: true
      t.string :registration_id

      t.timestamps null: false
    end
  end
end
