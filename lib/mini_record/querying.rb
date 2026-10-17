# frozen_string_literal: true

module MiniRecord
  module Querying
    QUERYING_METHODS = %i[
      find find_by find_by! first last where order reverse_order limit exists? count pluck destroy_all
    ].freeze

    extend MiniSupport::Concern

    class_methods do
      # Ideally delegate(*QUERYING_METHODS, to: :all), but delegate isn't implemented yet, so define_method is used
      # https://github.com/rails/rails/blob/c0c715b66e98dee1436f06ef682c42ab1de0c7e1/activerecord/lib/active_record/querying.rb#L5-L24
      QUERYING_METHODS.each do |name|
        define_method(name) { |*args, &block| all.public_send(name, *args, &block) }
      end

      # ActiveRecord::Scoping::Named#all isn't implemented yet either, so this is a stopgap
      def all
        Relation.new(self)
      end
    end
  end
end
