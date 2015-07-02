class PersonalFave
  include Cequel::Record

  key :user_id, :uuid
  key :content_url, :text
  column :headline, :text
  column :header_image_url, :text
  column :following_fave_count, :int
end
