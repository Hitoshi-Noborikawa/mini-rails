# frozen_string_literal: true

module MiniView
  class Renderer
    include Helpers

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

    private

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
