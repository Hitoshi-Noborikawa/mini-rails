# frozen_string_literal: true

module MiniRecord
  class RecordNotFound < StandardError; end

  class RecordInvalid < StandardError
    attr_reader :record

    def initialize(record)
      @record = record
      super(record.errors.full_messages.join(', '))
    end
  end

  class Base
    include MiniModel::Validations
    include MiniRecord::Associations
    include MiniRecord::ConnectionHandling
    include MiniRecord::ModelSchema
    include MiniRecord::Persistence
    include MiniRecord::Timestamp

    define_callbacks :save, :create, :update

    @@connection = nil

    def initialize(attrs = {})
      self.class.setup_attribute_methods!
      @persisted = false
      attrs.each { |k, v| send("#{k}=", v) }
    end

    def persisted?
      @persisted
    end

    class << self
      # 初回呼び出し時に1度だけ実行。column_names から動的に attribute accessors を生やす
      def setup_attribute_methods!
        return if @attribute_methods_set

        column_names.each do |col|
          define_method(col)       { instance_variable_get("@#{col}") }
          define_method("#{col}=") { instance_variable_set("@#{col}", _1) }
        end

        @attribute_methods_set = true
      end

      # DB から取り出した row を Model のインスタンスに変換する
      def instantiate(row)
        setup_attribute_methods!
        # column_names: ['id', 'title', 'body', ...]
        # row    : [1, 'Hello', 'World', ...]
        # => {'id' => 1, 'title' => 'Hello', ...}
        attrs = column_names.zip(row).to_h
        instance = new(attrs)
        instance.instance_variable_set(:@persisted, true)
        instance
      end

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

      def create(attrs)
        new(attrs).tap(&:save)
      end

      def create!(attrs)
        new(attrs).tap(&:save!)
      end
    end
  end
end
