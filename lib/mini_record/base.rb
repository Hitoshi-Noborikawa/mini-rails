# frozen_string_literal: true

module MiniRecord
  class Base
    include MiniModel::Validations
    include MiniRecord::Associations
    include MiniRecord::ConnectionHandling
    include MiniRecord::ModelSchema
    include MiniRecord::AttributeMethods
    include MiniRecord::Querying
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
  end
end
