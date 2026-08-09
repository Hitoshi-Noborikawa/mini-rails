# frozen_string_literal: true

module MiniSupport
  module Inflector
    module_function

    def pluralize(word)
      word + 's'
    end

    def singularize(word)
      word.end_with?('s') ? word.chomp('s') : word
    end

    # 'PostsController'     → 'posts_controller'
    # 'ActiveModel::Errors' → 'active_model/errors'
    # 'XMLHttpRequest'      → 'xml_http_request'
    def underscore(camel_cased_word)
      word = camel_cased_word.gsub('::', '/')
      word.gsub!(/(A-Z)+([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.downcase!
      word
    end

    # 'posts_controller' → 'PostsController'
    # 'admin/posts_controller' → 'Admin::PostsController'
    def camelize(term)
      term.split('/').map { |part| part.split('_').map(&:capitalize).join }.join('::')
    end

    # constantize('String')                    → String （文字列からクラスを返す）
    # constantize('Hash')                      → Hash
    # constantize('ActiveSupport::Inflector')  → ActiveSupport::Inflector（moduleも）
    def constantize(camel_cased_word)
      Object.const_get(camel_cased_word)
    end
  end
end
