# frozen_string_literal: true

require 'rack/session'
require 'dotenv/load'

require_relative 'config/environment'
require_relative 'config/routes'

use Rack::Session::Cookie, key: '_mini_rails_session', secret: ENV.fetch('SESSION_SECRET')

run MiniRails.application
