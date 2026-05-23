# frozen_string_literal: true

module MiniPack
  class Controller
    class << self
      # Router からリクエストごとに呼び出される。インスタンスを混ぜないため
      def dispatch(action, request, response, path_params)
        new.dispatch(action, request, response, path_params)
      end
    end

    attr_reader :request, :response

    def dispatch(action, request, response, path_params)
      @request = request
      @response = response
      @path_params = path_params
      process(action)
      to_rack_response
    end

    private

    def process(action)
      public_send(action)
    end

    def to_rack_response
      [response.status, response.headers, response.body]
    end

    # クエリパラメータ（?keyword=...）と form body と URL の path パラメータ（:id）を1つのハッシュにまとめる
    # シンボル・文字列キー両方で引けるようにするため
    def params
      @params ||= begin
        base = @request.params.transform_keys(&:to_sym)
        base.merge(@path_params)
      end
    end

    def render(plain: nil, html: nil, json: nil, status: 200)
      if plain
        @response.status = status
        @response['content-type'] = 'text/plain'
        @response.write(plain)
      elsif html
        @response.status = status
        @response['content-type'] = 'text/html'
        @response.write(html)
      elsif json
        @response.status = status
        @response['content-type'] = 'text/json'
        @response.write(json)
      end
    end

    def redirect_to(path, status: 302)
      @response.status = status
      @response.['location'] = path
    end
  end
end
