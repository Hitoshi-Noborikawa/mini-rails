# frozen_string_literal: true

module MiniView
  module Partial
    def render_partial(name, collection: nil, locals: {})
      path = partial_template_path(name)

      if collection
        collection.map { |item| render_partial_once(path, locals.merge(name.to_sym => item)) }.join
      else
        render_partial_once(path, locals)
      end
    end

    private

    def render_partial_once(path, locals)
      content = File.read(path)
      b = binding
      locals.each { |key, value| b.local_variable_set(key, value) }
      ERB.new(content, trim_mode: '-').result(b)
    end

    def partial_template_path(name)
      "app/views/#{controller_dir}/_#{name}.html.erb"
    end
  end
end
