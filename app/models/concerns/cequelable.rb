# TODO: Deprecate this
module Cequelable
  extend ActiveSupport::Concern

  included do
    def self.find_or_initialize_by(attributes, &block)
      where(attributes).first || new(attributes, &block)
    end
  end
end
