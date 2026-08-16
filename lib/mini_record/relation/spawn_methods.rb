# frozen_string_literal: true

module MiniRecord
  module SpawnMethods
    def spawn(new_values)
      self.class.new(@model_class, @values.merge(new_values))
    end
  end
end
