# frozen_string_literal: true

module MiniModel
  module Validations
    extend MiniSupport::Concern
    # Pushed onto @_dependencies.
    # Callbacks is included when MiniRecord::Base includes MiniModel::Validations
    include MiniSupport::Callbacks

    included do
      define_callbacks :validation
    end

    class_methods do
      # e.g. validates :title, presence: true
      def validates(attribute, options)
        validations << [attribute, options]
      end

      def validations
        @validations ||= []
      end

      def validate(method_name)
        custom_validations << method_name
      end

      def custom_validations
        @custom_validations ||= []
      end
    end

    def errors
      @errors ||= Errors.new
    end

    def valid?
      errors.clear
      # run_callbacks returns false when before_validation throws :abort
      result = run_callbacks(:validation) { run_validates; true }
      result && errors.empty?
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

      self.class.custom_validations.each { public_send(_1) }
    end

    # validator_type = :presence, validator_arg = true
    # Only presence and length for now. Add more branches as needed
    def run_validator(validator_type, attribute, validator_arg)
      case validator_type
      when :presence
        validate_presence(attribute) if validator_arg
      when :length
        validate_length(attribute, validator_arg) if validator_arg
      else
        raise NotImplementedError, "Unknown validator: #{validator_type}"
      end
    end

    def validate_presence(attribute)
      value = public_send(attribute)
      errors.add(attribute, "can't be blank") if value.nil? || value.to_s.strip.empty?
    end

    def validate_length(attribute, options)
      value = public_send(attribute)
      return if value.nil?

      if options[:maximum] && value.length > options[:maximum]
        errors.add(attribute, "is too long (maximum is #{options[:maximum]} characters)")
      end
    end
  end
end
