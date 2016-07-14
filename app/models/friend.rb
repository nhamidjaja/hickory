# frozen_string_literal: true
class Friend
  include Cequel::Record

  belongs_to :c_user
  key :id, :uuid
end
