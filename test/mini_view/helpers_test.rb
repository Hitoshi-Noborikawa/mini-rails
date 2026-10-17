# frozen_string_literal: true

require_relative '../test_helper'

class HelpersTest < TestCase
  include MiniView::Helpers

  test 'link_to returns an a tag' do
    assert_equal '<a href="/posts">Posts</a>', link_to('Posts', '/posts')
  end

  test 'text_field escapes the value' do
    assert_equal '<input type="text" name="title" value="&lt;b&gt;">', text_field(:title, '<b>')
  end

  test 'text_area escapes the content' do
    assert_equal '<textarea name="body">&lt;b&gt;</textarea>', text_area(:body, '<b>')
  end

  test 'truncate cuts the text and appends ...' do
    assert_equal 'Hello...', truncate('Hello, World', 5)
  end

  test 'truncate returns short text as is' do
    assert_equal 'Hello', truncate('Hello', 5)
  end

  test 'truncate escapes HTML' do
    assert_equal '&lt;b&gt;', truncate('<b>', 5)
  end

  test 'format_date formats a time String as a date' do
    assert_equal '2026/08/01', format_date('2026-08-01 10:00:00 +0900')
  end

  test 'format_date returns an empty String for nil' do
    assert_equal '', format_date(nil)
  end

  test 'method_field returns a hidden _method field' do
    assert_equal '<input type="hidden" name="_method" value="delete">', method_field(:delete)
  end
end
