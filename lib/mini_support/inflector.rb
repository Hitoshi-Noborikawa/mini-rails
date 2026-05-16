# frozen_string_literal: true

module Mini_Support
  module Inflector
    module_function

    def pluralize(word)
      word + 's'
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
    def camelize(term)
      term.split('_').map(&:capitalize).join
    end

    # constantize('String')                    → String （文字列からクラスを返す）
    # constantize('Hash')                      → Hash
    # constantize('ActiveSupport::Inflector')  → ActiveSupport::Inflector（moduleも）
    def constantize()
      Object.const_get(camel_cased_word)
    end
  end
end
