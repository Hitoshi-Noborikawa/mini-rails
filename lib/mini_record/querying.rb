# frozen_string_literal: true

module MiniRecord
  module Querying
    QUERYING_METHODS = %i[find first last where order reverse_order limit count].freeze

    extend MiniSupport::Concern

    class_methods do
      # delegate(*QUERYING_METHODS, to: :all) したいが、まだ作っていないので define_method している
      # https://github.com/rails/rails/blob/c0c715b66e98dee1436f06ef682c42ab1de0c7e1/activerecord/lib/active_record/querying.rb#L5-L24
      QUERYING_METHODS.each do |name|
        define_method(name) { |*args, &block| all.public_send(name, *args, &block) }
      end

      # ここも ActiveRecord::Scoping::Named#all をまだ作っていないので一旦これで対応
      def all
        Relation.new(self)
      end
    end
  end
end
