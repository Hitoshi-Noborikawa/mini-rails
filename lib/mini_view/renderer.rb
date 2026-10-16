# frozen_string_literal: true

module MiniView
  class Renderer
    include Helpers
    include Partial
    include MiniPack::UrlHelpers

    def initialize(controller)
      @_controller = controller

      controller.instance_variables.each do |ivar|
        next if ivar.to_s.start_with?('@_')

        instance_variable_set(ivar, controller.instance_variable_get(ivar))
      end
    end

    def render(action = nil, partial: nil, collection: nil, locals: {})
      if partial
        render_partial(partial, collection: collection, locals: locals)
      else
        action_html = render_template(action_template_path(action))
        render_layout { action_html }
      end
    end

    def flash
      @_controller.flash
    end

    private

    LAYOUT_PATH = 'app/views/layouts/application.html.erb'

    def render_layout(&block)
      return yield unless File.exist?(LAYOUT_PATH)

      content = File.read(LAYOUT_PATH)
      ERB.new(content, trim_mode: '-').result(binding)
    end

    def render_template(path)
      content = File.read(path)
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
