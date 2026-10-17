# frozen_string_literal: true

require_relative '../test_helper'

class HashWithIndifferentAccessTest < TestCase
  test 'reads a value stored with a Symbol key by its String key' do
    hash = MiniSupport::HashWithIndifferentAccess.new
    hash[:title] = 'Hello'

    assert_equal 'Hello', hash['title']
  end

  test 'reads a value stored with a String key by its Symbol key' do
    hash = MiniSupport::HashWithIndifferentAccess.new
    hash['title'] = 'Hello'

    assert_equal 'Hello', hash[:title]
  end

  test 'merge converts Symbol keys of the given Hash to String keys' do
    hash = MiniSupport::HashWithIndifferentAccess.new
    hash[:title] = 'Hello'

    merged = hash.merge(title: 'Bye', body: 'World')

    assert_equal({ 'title' => 'Bye', 'body' => 'World' }, merged.to_h)
    assert_instance_of MiniSupport::HashWithIndifferentAccess, merged
  end
end
