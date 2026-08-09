# frozen_string_literal: true

module MiniRails
  class Application
    AUTOLOAD_PATHS = ['app/models', 'app/controllers'].freeze

    def routes
      @routes ||= MiniPack::Router.new
    end

    def setup!
     AUTOLOAD_PATHS.each { |dir| autoloader.push_dir(dir) }
     autoloader.setup
     self
    end

    def call(env)
      routes.call(env)
    end

    private

    def autoloader
      @autoloader ||= Autoloader.new
    end
  end
end
