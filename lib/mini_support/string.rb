# frozen_string_literal: true

class String
  def pluralize
    MiniSupport::Inflector.pluralize(self)
  end

  def singularize
    MiniSupport::Inflector.singularize(self)
  end

  def underscore
    MiniSupport::Inflector.underscore(self)
  end

  def camelize
    MiniSupport::Inflector.camelize(self)
  end

  def constantize
    MiniSupport::Inflector.constantize(self)
  end
end
