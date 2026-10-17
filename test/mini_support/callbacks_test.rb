# frozen_string_literal: true

require_relative '../test_helper'

class CallbacksTest < TestCase
  class Recorder
    include MiniSupport::Callbacks

    define_callbacks :save

    before_save :record_before
    after_save :record_after

    attr_reader :log

    def initialize
      @log = []
    end

    def save
      run_callbacks(:save) do
        @log << :save
        :saved
      end
    end

    def record_before
      @log << :before
    end

    def record_after
      @log << :after
    end
  end

  class AbortingRecorder
    include MiniSupport::Callbacks

    define_callbacks :save

    before_save :abort
    after_save :record_after

    attr_reader :log

    def initialize
      @log = []
    end

    def save
      run_callbacks(:save) { @log << :save }
    end

    def abort
      throw :abort
    end

    def record_after
      @log << :after
    end
  end

  test 'runs before callbacks, the block, then after callbacks' do
    recorder = Recorder.new

    recorder.save

    assert_equal [:before, :save, :after], recorder.log
  end

  test 'run_callbacks returns the value of the block' do
    assert_equal :saved, Recorder.new.save
  end

  test 'throw :abort in a before callback skips the block and after callbacks and returns false' do
    recorder = AbortingRecorder.new

    result = recorder.save

    assert_equal false, result
    assert_empty recorder.log
  end
end
