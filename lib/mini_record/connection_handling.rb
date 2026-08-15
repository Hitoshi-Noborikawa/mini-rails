# frozen_string_literal: true

module MiniRecord
  module ConnectionHandling
    extend MiniSupport::Concern

    class_methods do
      def establish_connection(database_path)
        @@connection = Connection.new(database_path)
      end

      def connection
        @@connection
      end
    end
  end
end
