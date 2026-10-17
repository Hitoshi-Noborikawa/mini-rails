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
      # Needed for Post.limit(3).last. Reversing the order would return a different record
      return to_a.last if limit_value

      reverse_order.limit(1).to_a.first
    end

    def find_by(conditions)
      where(conditions).first
    end

    def find_by!(conditions)
      find_by(conditions) || raise(RecordNotFound, "#{@model_class.name} not found: #{conditions.inspect}")
    end

    def exists?
      !limit(1).to_a.empty?
    end

    private

    def ordered_relation
      order_values.empty? ? order(:id) : self
    end
  end
end
