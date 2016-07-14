# frozen_string_literal: true
class NilUser
  def following?(_target)
    false
  end
end
