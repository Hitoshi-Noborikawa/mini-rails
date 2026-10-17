# frozen_string_literal: true

module MiniRecord
  module ModelSchema
    extend MiniSupport::Concern

    class_methods do
      def table_name
        # name is Class#name, which returns the class name as a String
        name.underscore.pluralize
      end

      # Fetches column info with PRAGMA table_info(posts)
      # Each row is [cid, name, type, notnull, dflt_value, pk]
      # Only name is used here
      def column_names
        @column_names ||= connection.execute("PRAGMA table_info(#{table_name})").map { _1[1] }
      end
    end
  end
end
