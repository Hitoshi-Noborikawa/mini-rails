# frozen_string_literal: true

require_relative 'lib/mini_rails'
require_relative 'app/controllers/posts_controller'
require_relative 'config/routes'

run MiniRails::application
