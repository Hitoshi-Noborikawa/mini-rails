# frozen_string_literal: true

module MiniModel
  class Errors
    def initialize
      @messages = Hash.new { |h, k| h[k] = [] }
    end

    def add(attribute, message)
      @messages[attribute] << message
    end

    # 例: post.errors[:title] => ["can't be blank"]
    def [](attribute)
      @messages[attribute]
    end

    def empty?
      @messages.values.all?(&:empty?)
    end

    def any?
      !empty?
    end

    def clear
      @messages.clear
    end

    # ['Title can't be blank', ...] の形に整形する
    def full_messages
      @messages.flat_map do |attribute, messages|
        messages.map { |message| "#{attribute.to_s.capitalize} #{message}" }
      end
    end
  end
end
