module Fave
  class Url
    @parsed = nil

    def initialize(uri_string)
      @parsed = URI.parse(uri_string)
    end

    def canon
      (@parsed.host + @parsed.path).chomp('/')
    end
  end
end
