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
    HTTP_METHODS %i[get post patch put delete].freeze

    def initialize
      @routes = []
    end

    # 例:
    # routes.draw do
    #   get '/posts', to: 'posts#index'
    # end
    def draw(&block)
      instance_eval(&block)
    end

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
        param_names << Regex.last_match(1)
        "(?<#{Regexp.last_match(1)}>[^/+])"
      end
      [/\A#{regex_source}\z/, param_names]
    end
  end
end
