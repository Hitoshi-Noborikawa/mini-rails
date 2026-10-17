# frozen_string_literal: true

module MiniSupport
  module Concern
    # Called when a module does `extend MiniSupport::Concern`
    def self.extended(base)
      base.instance_variable_set(:@_included_block, nil)
      base.instance_variable_set(:@_dependencies, [])
    end

    def included(base = nil, &block)
      if base.nil?
        # With a block, as in included do ... end, store it for later
        @_included_block = block
      else
        super
      end
    end

    def class_methods(&block)
      mod = const_defined?(:ClassMethods, false) ? const_get(:ClassMethods) : const_set(:ClassMethods, Module.new)
      mod.module_eval(&block)
    end

    def append_features(base)

      if base.instance_variable_defined?(:@_dependencies)
        # Only modules extend MiniSupport::Concern, so this base is a concern, not a class
        base.instance_variable_get(:@_dependencies) << self
        false
      else
        # Return if base already includes self, to avoid including it twice
        return false if base < self

        @_dependencies.each { base.include(_1) }
        super
        base.extend(const_get(:ClassMethods)) if const_defined?(:ClassMethods, false)
        base.class_eval(&@_included_block) if @_included_block
      end
    end
  end
end
