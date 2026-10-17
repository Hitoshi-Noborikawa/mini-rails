# frozen_string_literal: true

module MiniPack
  # method:      HTTP method (:get / :post / ...)
  # pattern:     the original URL String ('/posts/:id')
  # regex:       pattern compiled into a Regexp for matching
  #               ('/posts/:id' → /\A\/posts\/(?<id>[^\/]+)\z/)
  # param_names: the "name" parts of each :name in pattern.
  #               '/posts/:id' → ['id']
  #               '/users/:user_id/posts/:id' → ['user_id', 'id']
  #               After a request matches, each value is taken with match[name] to build params like params[:id] = '42'.
  # controller:  controller name String such as 'posts'
  #               (constantized into PostsController on dispatch)
  # action:      action name String such as 'index'
  Route = Struct.new(:method, :pattern, :regex, :param_names, :controller, :action)

  class Router
    def initialize
      @routes = []
    end

    # e.g.
    # routes.draw do
    #   get '/posts', to: 'posts#index'
    # end
    def draw(&block)
      Mapper.new(@routes).instance_eval(&block)
    end

    # Takes env and returns [status, headers, body]
    def call(env)
      request = Rack::Request.new(env)
      http_method = http_method_for(request)
      path = request.path_info

      @routes.each do |route|
        next unless route.method == http_method

        match = route.regex.match(path)
        next unless match

        # Rack's PATH_INFO is ASCII-8BIT, so values captured by the Regexp are ASCII-8BIT too.
        # SQLite3 binds them as BLOBs that never match an integer id,
        # so the encoding is switched to UTF-8 before passing them on.
        path_params = route.param_names.to_h do |name|
          [name.to_sym, match[name].dup.force_encoding(Encoding::UTF_8)]
        end
        return dispatch(route, request, path_params)
      end

      not_found
    end

    private

    # Methods other than POST are used as is. Only POST honors _method,
    # matching Rack::MethodOverride
    def http_method_for(request)
      actual = request.request_method.downcase.to_sym
      return actual unless actual == :post

      override = request.params['_method']
      override ? override.downcase.to_sym : :post
    end

    def dispatch(route, request, path_params)
      controller_class = "#{route.controller}_controller".camelize.constantize
      response = Rack::Response.new
      controller_class.dispatch(route.action.to_sym, request, response, path_params)
    rescue MiniRecord::RecordNotFound
      not_found
    end

    def not_found
      [404, { 'content-type' => 'text/plain' }, ['Not Found']]
    end
  end
end
