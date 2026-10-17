# frozen_string_literal: true

require_relative 'mini_support'
# Loaded before mini_record so that MiniRecord::Base can include it
require_relative 'mini_model'
require_relative 'mini_record'
require_relative 'mini_pack'
require_relative 'mini_view'
require_relative 'mini_rails/autoloader'
require_relative 'mini_rails/application'

module MiniRails
  class << self
    def application
      @application ||= Application.new
    end
  end
end
