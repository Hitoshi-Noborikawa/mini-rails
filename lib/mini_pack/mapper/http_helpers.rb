# frozen_string_literal: true

module MiniPack
  class Mapper
    module HttpHelpers
      HTTP_METHODS = %i[get post patch put delete].freeze

      HTTP_METHODS.each do |http_method|
        define_method(http_method) do |pattern, to:|
          add_route(http_method, pattern, to)
        end
      end

      private

      # to: 'posts#index' を ['posts', 'index'] に分けて Route として積む
      def add_route(method, pattern, to)
        controller, action = to.split('#')
        regex, param_names = compile_pattern(pattern)
        @routes << Route.new(method, pattern, regex, param_names, controller, action)
      end

      # 例: '/posts/:id' → /\A\/posts\/(?<id>[^\/]+)\z/ と ['id']
      def compile_pattern(pattern)
        param_names = []
        regex_source = pattern.gsub(/:(\w+)/) do
          param_names << Regexp.last_match(1)
          "(?<#{Regexp.last_match(1)}>[^/]+)"
        end
        [/\A#{regex_source}\z/, param_names]
      end
    end
  end
end
