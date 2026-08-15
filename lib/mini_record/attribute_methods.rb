# frozen_string_literal: true

module MiniRecord
  module AttributeMethods
    extend MiniSupport::Concern

    class_methods do
      # 初回呼び出し時に1度だけ実行。column_names から動的に attribute accessors を生やす
      def setup_attribute_methods!
        return if @attribute_methods_set

        column_names.each do |column_name|
          define_method(column_name)       { instance_variable_get("@#{column_name}") }
          define_method("#{column_name}=") { instance_variable_set("@#{column_name}", _1) }
        end

        @attribute_methods_set = true
      end
    end
  end
end
