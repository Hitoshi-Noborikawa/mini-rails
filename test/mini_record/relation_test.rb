# frozen_string_literal: true

require_relative '../test_helper'

class RelationTest < TestCase
  def setup
    super
    @first = Post.create!(title: 'First', published: 1, created_at: '2026-08-01 10:00:00 +0900')
    @second = Post.create!(title: 'Second', published: 2, created_at: '2026-08-03 10:00:00 +0900')
    @third = Post.create!(title: 'Third', published: nil, created_at: '2026-08-02 10:00:00 +0900')
  end

  test 'where filters by equality' do
    assert_equal ['Second'], Post.where(title: 'Second').map(&:title)
  end

  test 'where with nil filters by IS NULL' do
    assert_equal ['Third'], Post.where(published: nil).map(&:title)
  end

  test 'where with an Array filters by IN' do
    assert_equal ['First', 'Third'], Post.where(title: ['First', 'Third']).order(:id).map(&:title)
  end

  test 'where with an empty Array returns nothing' do
    assert_empty Post.where(title: []).to_a
  end

  test 'where with an inclusive Range includes the end' do
    assert_equal ['First', 'Second'], Post.where(published: 1..2).order(:id).map(&:title)
  end

  test 'where with an exclusive Range excludes the end' do
    assert_equal ['First'], Post.where(published: 1...2).map(&:title)
  end

  test 'where with a record filters by its id' do
    comment = Comment.create!(post_id: @second.id, body: 'Nice')

    assert_equal [comment.id], Comment.where(post_id: @second).map(&:id)
  end

  test 'chained where conditions are combined with AND' do
    assert_empty Post.where(title: 'First').where(published: 2).to_a
  end

  test 'where with an unknown column raises ArgumentError' do
    assert_raises(ArgumentError) { Post.where(unknown: 1) }
  end

  test 'where returns a new Relation without changing the original' do
    relation = Post.all

    relation.where(title: 'First')

    assert_equal 3, relation.count
  end

  test 'order with a Symbol sorts ascending' do
    assert_equal ['First', 'Third', 'Second'], Post.order(:created_at).map(&:title)
  end

  test 'order with desc in a Hash sorts descending' do
    assert_equal ['Second', 'Third', 'First'], Post.order(created_at: :desc).map(&:title)
  end

  test 'order with an invalid direction raises ArgumentError' do
    assert_raises(ArgumentError) { Post.order(created_at: :sideways) }
  end

  test 'reverse_order flips the order direction' do
    assert_equal ['Second', 'Third', 'First'], Post.order(:created_at).reverse_order.map(&:title)
  end

  test 'limit restricts the number of records' do
    assert_equal ['First', 'Second'], Post.order(:id).limit(2).map(&:title)
  end

  test 'first returns the lowest id without an order' do
    assert_equal 'First', Post.first.title
  end

  test 'first follows the given order' do
    assert_equal 'Second', Post.order(created_at: :desc).first.title
  end

  test 'last returns the highest id without an order' do
    assert_equal 'Third', Post.last.title
  end

  test 'last returns the last record within the limit' do
    assert_equal 'Second', Post.order(:id).limit(2).last.title
  end

  test 'find returns the record by id' do
    assert_equal 'Second', Post.find(@second.id).title
  end

  test 'find accepts a String id' do
    assert_equal 'Second', Post.find(@second.id.to_s).title
  end

  test 'find raises RecordNotFound when no record matches' do
    assert_raises(MiniRecord::RecordNotFound) { Post.find(0) }
  end

  test 'find with a block behaves like Enumerable#find' do
    assert_equal 'Third', Post.all.find { _1.published.nil? }.title
  end

  test 'find_by returns the first match or nil' do
    assert_equal @first.id, Post.find_by(published: 1).id
    assert_nil Post.find_by(published: 99)
  end

  test 'find_by! raises RecordNotFound when no record matches' do
    assert_raises(MiniRecord::RecordNotFound) { Post.find_by!(published: 99) }
  end

  test 'exists? tells whether any record matches' do
    assert Post.where(title: 'First').exists?
    refute Post.where(title: 'Fourth').exists?
  end

  test 'count returns the number of filtered records' do
    assert_equal 2, Post.where(title: ['First', 'Second']).count
  end

  test 'pluck with one column returns an Array of values' do
    assert_equal ['First', 'Second', 'Third'], Post.order(:id).pluck(:title)
  end

  test 'pluck with several columns returns an Array per row' do
    assert_equal [['First', 1], ['Second', 2]], Post.where(published: 1..2).order(:id).pluck(:title, :published)
  end

  test 'build takes equality conditions from where as attributes' do
    post = Post.where(title: 'Draft', published: [1, 2]).build(body: 'World')

    assert_equal 'Draft', post.title
    assert_nil post.published
    assert_equal 'World', post.body
  end

  test 'destroy_all deletes all filtered records' do
    Post.where(published: 1..2).destroy_all

    assert_equal ['Third'], Post.all.map(&:title)
  end
end
