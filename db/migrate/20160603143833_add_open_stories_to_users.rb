class AddOpenStoriesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :open_stories, :boolean, null: false, default: false
  end
end
