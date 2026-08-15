# frozen_string_literal: true

module MiniRecord
  class Base
    include MiniModel::Validations
    include MiniRecord::Associations
    include MiniRecord::ConnectionHandling
    include MiniRecord::ModelSchema
    include MiniRecord::AttributeMethods
    include MiniRecord::Persistence
    include MiniRecord::Timestamp

    define_callbacks :save, :create, :update

    def initialize(attrs = {})
      self.class.setup_attribute_methods!
      @persisted = false
      attrs.each { |k, v| send("#{k}=", v) }
    end

    def persisted?
      @persisted
    end

    class << self
      def find(id)
        rows = connection.execute(
          "SELECT * FROM #{table_name} WHERE id = ? LIMIT 1",
          id
        )
        raise RecordNotFound, "#{name} not found: id=#{id}" if rows.empty?

        instantiate(rows.first)
      end

      def all
        Relation.new(self)
      end

      def where(conditions)
        Relation.new(self, conditions)
      end
    end
  end
end
