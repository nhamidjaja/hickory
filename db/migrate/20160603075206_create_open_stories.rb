class CreateOpenStories < ActiveRecord::Migration
  def change
    create_table :open_stories, id: false do |t|
      t.uuid :id, primary_key: true
      t.uuid :faver_id, null: false
      t.string :content_url, null: false
      t.string :title
      t.string :image_url
      t.timestamp :published_at
      t.timestamp :faved_at, null: false

      t.timestamps null: false
    end

    add_index :open_stories, :faved_at, order: { faved_at: :desc }
  end
end
