# frozen_string_literal: true

module MiniRecord
  module FinderMethods
    def find(*args, &block)
      return super if block
      raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 1)" unless args.size == 1

      id = args.first
      record = where(id: id).to_a.first
      raise RecordNotFound, "#{@model_class.name} not found: id=#{id}" unless record

      record
    end

    def first
      ordered_relation.limit(1).to_a.first
    end

    def last
      # Post.limit(3).last に対応するため。reverse してしまうと異なる結果を返してしまう
      return to_a.last if limit_value

      reverse_order.limit(1).to_a.first
    end
  end
end
