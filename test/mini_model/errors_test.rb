# frozen_string_literal: true

require_relative '../test_helper'

class ErrorsTest < TestCase
  test 'returns added messages per attribute' do
    errors = MiniModel::Errors.new
    errors.add(:title, "can't be blank")

    assert_equal ["can't be blank"], errors[:title]
    assert_equal [], errors[:body]
  end

  test 'stays empty after reading an attribute without errors' do
    errors = MiniModel::Errors.new

    errors[:title]

    assert_predicate errors, :empty?
  end

  test 'full_messages prefixes each message with the capitalized attribute name' do
    errors = MiniModel::Errors.new
    errors.add(:title, "can't be blank")
    errors.add(:body, 'is too long (maximum is 1000 characters)')

    assert_equal ["Title can't be blank", 'Body is too long (maximum is 1000 characters)'], errors.full_messages
  end

  test 'clear removes all errors' do
    errors = MiniModel::Errors.new
    errors.add(:title, "can't be blank")

    errors.clear

    assert_predicate errors, :empty?
  end
end
