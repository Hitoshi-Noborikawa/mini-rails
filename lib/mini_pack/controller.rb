# frozen_string_literal: true

module MiniPack
  class Controller
    include MiniPack::UrlHelpers

    class << self
      # Router からリクエストごとに呼び出される。インスタンスを混ぜないため
      def dispatch(action, request, response, path_params)
        new.dispatch(action, request, response, path_params)
      end

      def before_action(method_name, only: [], except: [])
        before_action_filters << { method: method_name, only: Array(only), except: Array(except) }
      end

      def before_action_filters
        @before_action_filters ||= []
      end
    end

    attr_reader :request, :response

    def dispatch(action, request, response, path_params)
      @request = request
      @response = response
      @path_params = path_params
      process(action)
      flash.persist!
      to_rack_response
    end

    def flash
      @flash ||= Flash.new(session)
    end

    private

    def process(action)
      self.class.before_action_filters.each do |filter|
        next unless filter_applies?(filter, action)
        send(filter[:method])
        return if @_rendered
      end

      public_send(action)
      # action が明示的に render を呼び出さなかった時のフォールバック
      default_render(action) unless @_rendered
    end

    def filter_applies?(filter, action)
      only = filter[:only]
      except = filter[:except]

      return false if only.any? && !only.include?(action)
      return false if except.any? && except.include?(action)
      true
    end

    def session
      @request.session
    end

    def default_render(action)
      render(template: action)
    end

    def to_rack_response
      [response.status, response.headers, response.body]
    end

    # クエリ (?keyword=...) と form ボディと URL の path パラメータ (:id) を1つの Hash にまとめる。
    # キーは Symbol で統一する（Rails の HashWithIndifferentAccess 相当はミニ版では未実装）。
    def params
      @params ||= begin
        base = @request.params.transform_keys(&:to_sym)
        base.merge(@path_params)
      end
    end

    def render(plain: nil, html: nil, json: nil, template: nil, status: 200)
      @_rendered = true

      if plain
        @response.status = status
        @response['content-type'] = 'text/plain'
        @response.write(plain)
      elsif html
        @response.status = status
        @response['content-type'] = 'text/html charset=utf-8'
        @response.write(html)
      elsif json
        @response.status = status
        @response['content-type'] = 'application/json'
        @response.write(JSON.generate(json))
      elsif template
        @response.status = status
        @response['content-type'] = 'text/html'
        @response.write(MiniView::Renderer.new(self).render(template))
      end
    end

    def redirect_to(path, status: 302)
      @_rendered = true
      @response.status = status
      @response['location'] = path
    end
  end
end
