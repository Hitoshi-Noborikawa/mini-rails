# frozen_string_literal: true

require_relative 'lib/mini_rails'
require_relative 'app/controllers/posts_controller'
require_relative 'config/routes'

MiniRecord::Base.establish_connection('db/development.sqlite3')

require_relative 'app/models/post'

run MiniRails::application
