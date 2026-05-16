# frozen_string_literal: true

module MiniRails
  class Application
    def call(env)
      [200, { "content-type" => "text/plain" }, ["Hello, mini-rails"]]
    end
  end
end
