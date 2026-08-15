# frozen_string_literal: true

module MiniRecord
  class << self
    attr_accessor :verbose
  end
end

require_relative 'mini_record/errors'
require_relative 'mini_record/connection'
require_relative 'mini_record/connection_handling'
require_relative 'mini_record/model_schema'
require_relative 'mini_record/attribute_methods'
require_relative 'mini_record/associations'
require_relative 'mini_record/persistence'
require_relative 'mini_record/timestamp'
require_relative 'mini_record/base'
require_relative 'mini_record/relation'
require_relative 'mini_record/table_definition'
require_relative 'mini_record/migration'
require_relative 'mini_record/schema_migration'
require_relative 'mini_record/migrator'
