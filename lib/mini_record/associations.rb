# frozen_string_literal: true

module MiniRecord
  module Associations
    extend MiniSupport::Concern

    class_methods do
      def belongs_to(name)
        foreign_key = "#{name}_id"

        define_method(name) do
          id = public_send(foreign_key)
          return nil if id.nil?

          name.to_s.camelize.constantize.find(id)
        end

        define_method("#{name}=") do |record|
          public_send("#{foreign_key}=", record&.id)
        end
      end

      def has_many(name)
        define_method(name) do
          foreign_key = "#{self.class.name.underscore}_id"
          name.to_s.singularize.camelize.constantize.where(foreign_key => id)
        end
      end
    end
  end
end
