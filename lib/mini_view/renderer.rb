# frozen_string_literal: true

module MiniView
  class Renderer
    include Helpers
    include MiniPack::UrlHelpers

    def initialize(controller)
      @_controller = controller

      controller.instance_variables.each do |ivar|
        # 内部用の ivar は使わないので外す
        next if ivar.to_s.start_with?('@_')

        instance_variable_set(ivar, controller.instance_variable_get(ivar))
      end
    end

    def render(action)
      action_html = render_template(action_template_path(action))
      render_layout { action_html }
    end

    def flash
      @_controller.flash
    end

    private

    LAYOUT_PATH = 'app/views/layouts/application.html.erb'

    # layout テンプレートを ERB でメソッド化して、block 付きで呼ぶ
    def render_layout(&block)
      return yield unless File.exist?(LAYOUT_PATH)

      content = File.read(LAYOUT_PATH)
      # この Renderer インスタンスだけの特異メソッドとして __layout__ を生やす
      # メソッド本体は layout の ERB をコンパイルした Ruby コード
      ERB.new(content, trim_mode: '-').def_method(singleton_class, '__layout__')
      # __layout__ を block 付きで呼ぶと、layout 内の <%= yield %> が
      # block の戻り値（action_html）で書き換わった HTMl 文字列が返る
      __layout__(&block)
    end

    def render_template(path)
      content = File.read(path)
      # binding を渡すことで Render インスタンスの self / ivars メソッドがテンプレート内から見えるようになる
      ERB.new(content, trim_mode: '-').result(binding)
    end

    def action_template_path(action)
      "app/views/#{controller_dir}/#{action}.html.erb"
    end

    # PostsController → 'posts'
    def controller_dir
      @_controller.class.name.sub(/Controller$/, '').underscore
    end
  end
end
