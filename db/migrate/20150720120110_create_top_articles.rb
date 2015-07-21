class CreateTopArticles < ActiveRecord::Migration
  def change
    create_table :top_articles, id: false do |t|
      t.string :content_url, primary_key: true
      t.uuid :feeder_id, null: false
      t.string :title
      t.string :image_url
      t.datetime :published_at

      t.timestamps null: false
    end
    add_index :top_articles, :published_at, order: { published_at: :desc }
    add_foreign_key :top_articles, :feeders
  end
end
