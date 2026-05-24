# frozen_string_literal: true

module MiniRails
  class Application
    def routes
      @routes ||= MiniPack::Router.new
    end

    def call(env)
      routes.call(env)
    end
  end
end
