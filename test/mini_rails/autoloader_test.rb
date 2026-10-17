# frozen_string_literal: true

require_relative '../test_helper'
require 'tmpdir'

class AutoloaderTest < TestCase
  def setup
    super
    @dir = Dir.mktmpdir
    File.write(File.join(@dir, 'autoload_sample.rb'), 'class AutoloadSample; end')
    Dir.mkdir(File.join(@dir, 'autoload_space'))
    File.write(File.join(@dir, 'autoload_space', 'item.rb'), 'class AutoloadSpace::Item; end')

    autoloader = MiniRails::Autoloader.new
    autoloader.push_dir(@dir)
    autoloader.setup
  end

  # Autoloader defines constants directly under Object, so they are removed to keep other tests unaffected
  def teardown
    Object.send(:remove_const, :AutoloadSample) if Object.const_defined?(:AutoloadSample, false)
    Object.send(:remove_const, :AutoloadSpace) if Object.const_defined?(:AutoloadSpace, false)
    FileUtils.remove_entry(@dir)
    super
  end

  test 'registers autoloads named after the files' do
    assert_equal File.join(@dir, 'autoload_sample.rb'), Object.autoload?(:AutoloadSample)
  end

  test 'loads the file when the constant is referenced' do
    assert_instance_of Class, AutoloadSample
  end

  test 'a directory becomes a namespace module with autoloads under it' do
    assert_instance_of Module, AutoloadSpace
    assert_equal File.join(@dir, 'autoload_space', 'item.rb'), AutoloadSpace.autoload?(:Item)
  end
end
