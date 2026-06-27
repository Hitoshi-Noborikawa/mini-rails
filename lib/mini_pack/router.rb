# frozen_string_literal: true

module MiniPack
  # method:      HTTP メソッド (:get / :post / ...)
  # pattern:     元の URL 文字列 ('/posts/:id')
  # regex:       マッチ判定用に pattern を変換した正規表現
  #               ('/posts/:id' → /\A\/posts\/(?<id>[^\/]+)\z/)
  # param_names: pattern に含まれる :name の "name" 部分を並べた配列。
  #               '/posts/:id' → ['id']
  #               '/users/:user_id/posts/:id' → ['user_id', 'id']
  #               リクエストが来てマッチした後、これを元に match[name] で値を取り出して params[:id] = '42' のように組み立てる。
  # controller:  'posts' のような controller 名文字列
  #               (dispatch 時に PostsController に constantize する)
  # action:      'index' のような action 名文字列
  Route = Struct.new(:method, :pattern, :regex, :param_names, :controller, :action)

  class Router
    def initialize
      @routes = []
    end

    # 例:
    # routes.draw do
    #   get '/posts', to: 'posts#index'
    # end
    def draw(&block)
      Mapper.new(@routes).instance_eval(&block)
    end

    # env を受け取って [status, headers, body] を返す
    def call(env)
      request = Rack::Request.new(env)
      http_method = http_method_for(request)
      path = request.path_info

      @routes.each do |route|
        next unless route.method == http_method

        match = route.regex.match(path)
        next unless match

        # Rack の PATH_INFO は ASCII-8BIT エンコーディングなので、正規表現で取り出した値も
        # ASCII-8BIT になる。そのまま SQLite3 に bind すると BLOB 扱いされて integer の id と
        # マッチしないので、UTF-8 にエンコーディングを差し替えてから渡す。
        path_params = route.param_names.to_h do |name|
          [name.to_sym, match[name].dup.force_encoding(Encoding::UTF_8)]
        end
        return dispatch(route, request, path_params)
      end

      not_found
    end

    private

    # このリクエストを処理すべき HTTP メソッドを返す
    # GET など POST 以外はそのままに、POST だけは _method が含まれていることを考慮する
    # （Rack::MethodOverride）に合わせている
    def http_method_for(request)
      actual = request.request_method.downcase.to_sym
      return actual unless actual == :post

      override = request.params['_method']
      override ? override.downcase.to_sym : :post
    end

    # Route から controller クラスを取得して dispatch する
    def dispatch(route, request, path_params)
      controller_class = "#{route.controller}_controller".camelize.constantize
      response = Rack::Response.new
      controller_class.dispatch(route.action.to_sym, request, response, path_params)
    end

    def not_found
      [404, { 'content-type' => 'text/plain' }, ['Not Found']]
    end
  end
end
