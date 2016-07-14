# frozen_string_literal: true
module Storyable
  extend ActiveSupport::Concern

  def counter
    @counter ||= FaveCounter.consistency(:one)
                            .find_or_initialize_by(
                              c_user_id: faver_id,
                              id: id
                            )

    @counter
  end

  def faver
    User.find(faver_id)
  end
end
