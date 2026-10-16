# frozen_string_literal: true

module MiniSupport
  module Concern
    # `extend MiniSupport::Concern` した際に呼び出される
    def self.extended(base)
      base.instance_variable_set(:@_included_block, nil)
      base.instance_variable_set(:@_dependencies, [])
    end

    def included(base = nil, &block)
      if base.nil?
        # included do ... end のように block であれば登録しておく
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
        # extend MiniSupport::Concern するのは module なので class じゃないと判定
        base.instance_variable_get(:@_dependencies) << self
        false
      else
        # self が base で既に include 済みであれば、二重になってしまうので抜ける
        return false if base < self

        @_dependencies.each { base.include(_1) }
        super
        base.extend(const_get(:ClassMethods)) if const_defined?(:ClassMethods, false)
        base.class_eval(&@_included_block) if @_included_block
      end
    end
  end
end
