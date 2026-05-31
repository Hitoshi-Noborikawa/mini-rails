# frozen_string_literal: true

require 'erb'

module MiniView
  module Helpers
    def link_to(text, path)
      %(<a href="#{path}">#{text}</a>)
    end

    def h(text)
      ERB::Util.html_escape(text)
    end

    def text_field(name, value = nil)
      %(<input type="text" name="#{name}" value="#{h(value)}">)
    end

    def text_area(name, value = nil)
      %(<textarea name="#{name}">#{h(value)}</textarea>)
    end

    def submit(text = 'Save')
      %(<input type="submit" value="#{text}">)
    end

    # PATCH / DELETE を送りたい時は POST にこの hidden field を追加しておく
    def method_field(method)
      %(<input type="hidden" name="_method" value="#{method}">)
    end
  end
end
