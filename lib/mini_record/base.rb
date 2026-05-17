# frozen_string_literal: true

module MiniRecord
  class Base
    @@connection = nil

    class << self
      def establish_connection(database_path)
        @@connection = Connection.new(database_path)
      end

      def connection
        @@connection
      end
    end
  end
end
