# frozen_string_literal: true

module MiniModel
  module Validations
    # ActiveModel::Validations が ActiveSupport::Concern を使ってやっていることを
    # mini-rails では self.included フックで再現
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # 例: validates :title, presence: true
      def validates(attribute, options)
        validations << [attribute, options]
      end

      def validations
        @validations ||= []
      end
    end

    def errors
      @errors ||= Errors.new
    end

    def valid?
      errors.clear
      run_validates
      errors.empty?
    end

    def invalid?
      !valid?
    end

    private

    def run_validates
      self.class.validations.each do |attribute, options|
        options.each do |validator_type, validator_arg|
          run_validator(validator_type, attribute, validator_arg)
        end
      end
    end

    # validator_type = :presence, validator_arg = true
    # 現状は presence のみ。将来的には分岐を増やしていけばOK
    def run_validator(validator_type, attribute, validator_arg)
      case validator_type
      when :presence
        validate_presence(attribute) if validator_arg
      else
        raise NotImplementedError, "Unknown validator: #{validator_type}"
      end
    end

    def validate_presence(attribute)
      value = public_send(attribute)
      errors.add(attribute, "can't be blank") if value.nil? || value.to_s.strip.empty?
    end
  end
end
