# frozen_string_literal: true

require_relative '../test_helper'

class ValidationsTest < TestCase
  class Article
    include MiniModel::Validations

    attr_accessor :title, :body

    validates :title, presence: true
    validates :body, length: { maximum: 5 }
    validate :title_must_not_be_draft

    def initialize(title: 'Hello', body: 'World')
      @title = title
      @body = body
    end

    def title_must_not_be_draft
      errors.add(:title, 'is draft') if title == 'draft'
    end
  end

  class GuardedArticle
    include MiniModel::Validations

    attr_accessor :title

    validates :title, presence: true
    before_validation :guard

    def guard
      throw :abort
    end
  end

  test 'valid? returns true when all validations pass' do
    assert_predicate Article.new, :valid?
  end

  test 'presence treats a whitespace-only string as blank' do
    article = Article.new(title: '   ')

    assert_predicate article, :invalid?
    assert_equal ["can't be blank"], article.errors[:title]
  end

  test 'length is valid at exactly the maximum' do
    assert_predicate Article.new(body: '12345'), :valid?
  end

  test 'length is invalid above the maximum' do
    article = Article.new(body: '123456')

    assert_predicate article, :invalid?
    assert_equal ['is too long (maximum is 5 characters)'], article.errors[:body]
  end

  test 'length skips nil' do
    assert_predicate Article.new(body: nil), :valid?
  end

  test 'methods registered with validate are run' do
    article = Article.new(title: 'draft')

    assert_predicate article, :invalid?
    assert_equal ['is draft'], article.errors[:title]
  end

  test 'valid? clears errors from the previous run' do
    article = Article.new(title: '')
    article.valid?

    article.title = 'Hello'

    assert_predicate article, :valid?
    assert_empty article.errors[:title]
  end

  test 'throw :abort in before_validation makes the record invalid without errors' do
    article = GuardedArticle.new
    article.title = 'Hello'

    assert_predicate article, :invalid?
    assert_predicate article.errors, :empty?
  end

  test 'an unknown validator raises NotImplementedError' do
    klass = Class.new do
      include MiniModel::Validations

      attr_accessor :title

      validates :title, uniqueness: true
    end

    assert_raises(NotImplementedError) { klass.new.valid? }
  end
end
