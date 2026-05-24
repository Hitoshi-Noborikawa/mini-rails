# frozen_string_literal: true

require_relative 'lib/mini_rails'
require_relative 'app/controllers/posts_controller'
require_relative 'config/routes'

MiniRecord::Base.establish_connection('db/development.sqlite3')

# 本来は app/models/post.rb に置くが、後ほど対応
class Post < MiniRecord::Base
end

run MiniRails::application
