# frozen_string_literal: true

require 'erb'

module MiniView
  module Helpers
    def lint_to(text, path)
      %(<a href="#{path}">#{text}</a>)
    end

    def h(text)
      ERB::Util.html_escape(text)
    end
  end
end
