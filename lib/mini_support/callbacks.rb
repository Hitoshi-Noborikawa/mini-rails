# frozen_string_literal: true

module MiniSupport
  module Callbacks
    extend MiniSupport::Concern

    class_methods do
      def define_callbacks(*events)
        events.each do |event|
          define_singleton_method("before_#{event}") do |*method_names|
            method_names.each { set_callback(event, :before, _1) }
          end

          define_singleton_method("after_#{event}") do |*method_names|
            method_names.each { set_callback(event, :after, _1) }
          end
        end
      end

      def set_callback(event, kind, method_name)
        callbacks[event][kind] << method_name
      end

      def callbacks
        @_callbacks ||= Hash.new { |hash, event| hash[event] = { before: [], after: [] } }
      end
    end

    def run_callbacks(event)
      list = self.class.callbacks[event]
      catch(:abort) do
        list[:before].each { public_send(_1) }
        result = block_given? ? yield : true
        list[:after].each { public_send(_1) }
        return result
      end
      false
    end
  end
end
