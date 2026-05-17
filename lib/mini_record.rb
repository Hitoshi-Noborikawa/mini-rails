# frozen_string_literal: true

module MiniRecord
  class << self
    attr_accessor :verbose
  end
end

require_relative 'mini_record/connection'
require_relative 'mini_record/base'
require_relative 'mini_record/relation'
