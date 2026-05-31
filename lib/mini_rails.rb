# frozen_string_literal: true

require_relative 'mini_support'
# mini_record よりも前に load させることで include できるようにしている
require_relative 'mini_model'
require_relative 'mini_record'
require_relative 'mini_pack'
require_relative 'mini_view'
require_relative 'mini_rails/application'

module MiniRails
  class << self
    def application
      @application ||= Application.new
    end
  end
end
