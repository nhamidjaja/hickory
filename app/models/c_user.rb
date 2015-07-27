# User representation in cassandra
class CUser
  include Cequel::Record

  key :id, :uuid

  has_many :c_user_faves
  has_many :c_user_fave_urls
end
