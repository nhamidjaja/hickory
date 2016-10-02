# frozen_string_literal: true
class NilUser
  def following?(_target)
    false
  end

  def subscribing?(_feeder)
    false
  end
end
