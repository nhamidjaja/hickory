class CreateFeeders < ActiveRecord::Migration
  def change
    create_table :feeders, id: :uuid do |t|
      t.string :feed_url, null: false
      t.string :title
      t.string :description

      t.timestamps null: false
    end
    add_index :feeders, :feed_url, unique: true
  end
end
