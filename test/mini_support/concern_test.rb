# frozen_string_literal: true

require_relative '../test_helper'

class ConcernTest < TestCase
  module Greetable
    extend MiniSupport::Concern

    included do
      attr_accessor :greeted
    end

    class_methods do
      def greeting
        'Hello'
      end
    end
  end

  # A concern that depends on Greetable, to check that the including class gets Greetable without knowing about it
  module Introducible
    extend MiniSupport::Concern
    include Greetable

    class_methods do
      def introduction
        "#{greeting}, I'm #{name}"
      end
    end
  end

  test 'methods defined in class_methods become class methods' do
    klass = Class.new { include Greetable }

    assert_equal 'Hello', klass.greeting
  end

  test 'the included block is evaluated in the including class' do
    klass = Class.new { include Greetable }

    assert_respond_to klass.new, :greeted=
  end

  test 'dependent concerns are included into the including class' do
    klass = Class.new do
      include Introducible

      def self.name
        'Alice'
      end
    end

    assert_equal "Hello, I'm Alice", klass.introduction
    assert_includes klass.ancestors, Greetable
  end

  test 'calling class_methods twice adds to the same ClassMethods' do
    mod = Module.new do
      extend MiniSupport::Concern

      class_methods do
        def first
          1
        end
      end

      class_methods do
        def second
          2
        end
      end
    end
    klass = Class.new { include mod }

    assert_equal [1, 2], [klass.first, klass.second]
  end
end
