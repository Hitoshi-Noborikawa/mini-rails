# frozen_string_literal: true

require_relative '../lib/mini_rails'

MiniRails.application.setup!
MiniRecord::Base.establish_connection('db/development.sqlite3')
