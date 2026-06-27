# frozen_string_literal: true

module MiniPack
  class Mapper
    include HttpHelpers
    include Resources

    def initialize(routes)
      @routes = routes
    end
  end
end
