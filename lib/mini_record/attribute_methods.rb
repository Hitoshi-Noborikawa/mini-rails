# frozen_string_literal: true

module MiniRecord
  module AttributeMethods
    extend MiniSupport::Concern

    class_methods do
      # Runs only once, on the first call. Defines attribute accessors dynamically from column_names
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
