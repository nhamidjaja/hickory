# frozen_string_literal: true
# TOOD: rename this class
module Fave
  class Url
    @parsed = nil

    def initialize(uri_string)
      @parsed = URI.parse(uri_string)
    end

    def canon
      ('http://' + @parsed.host + @parsed.path).chomp('/')
    end

    def valid?
      @parsed.is_a?(URI::HTTP)
    end
  end
end
