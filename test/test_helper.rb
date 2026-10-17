# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require 'rack/session'
require 'stringio'

require_relative '../lib/mini_rails'

# config/environment.rb connects to the development DB, so the test environment is built here instead.
# Corresponds to config/environments/test.rb in Rails.
MiniRails.application.setup!
MiniRecord::Base.establish_connection(':memory:')

# Corresponds to maintain_test_schema! in Rails. Migrator puts its progress, so stdout is silenced to keep it out of the test output
begin
  $stdout = StringIO.new
  MiniRecord::Migrator.run
ensure
  $stdout = STDOUT
end

require_relative '../config/routes'

# Corresponds to ActiveSupport::TestCase in Rails
class TestCase < Minitest::Test
  # Lets tests be written as test 'is invalid without a title' do ... end.
  # Like ActiveSupport::Testing::Declarative#test in Rails, it defines a method prefixed with test_.
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/, '_')}".to_sym
    raise "#{test_name} is already defined in #{self}" if method_defined?(test_name)

    define_method(test_name, &block)
  end

  # Like use_transactional_tests in Rails, each test is rolled back so no records leak into the next one
  def setup
    super
    MiniRecord::Base.connection.execute('BEGIN')
  end

  def teardown
    MiniRecord::Base.connection.execute('ROLLBACK')
    super
  end
end

# Corresponds to ActionDispatch::IntegrationTest in Rails, which also uses Rack::Test internally
class IntegrationTest < TestCase
  include Rack::Test::Methods

  def app
    @app ||= Rack::Builder.new do
      use Rack::Session::Cookie, key: '_mini_rails_session', secret: 'test' * 16
      run MiniRails.application
    end
  end
end
