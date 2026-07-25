# frozen_string_literal: true

require 'rack/session'
require 'dotenv/load'

require_relative 'lib/mini_rails'
require_relative 'app/controllers/posts_controller'
require_relative 'config/routes'

MiniRecord::Base.establish_connection('db/development.sqlite3')

require_relative 'app/models/post'
require_relative 'app/models/comment'

use Rack::Session::Cookie, key: '_mini_rails_session', secret: ENV.fetch('SESSION_SECRET')

run MiniRails::application
