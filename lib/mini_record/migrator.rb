# frozen_string_literal: true

module MiniRecord
  class Migrator
    MIGRATIONS_DIR = 'db/migrate'

    class << self
      def run
        SchemaMigration.ensure_table!
        executed = SchemaMigration.all_versions
        ran_any = false

        migration_files.each do |path|
          version, class_name = parse_filename(path)
          next if executed.include?(version)

          run_migration(path, class_name, direction: :up)
          SchemaMigration.record!(version)
          puts " #{class_name} (#{version}) ... done"
          ran_any = true
        end

        puts ' No new migrations' unless ran_any
      end

      def rollback
        SchemaMigration.ensure_table!
        latest_version = SchemaMigration.all_versions.sort.last

        if latest_version.nil?
          puts ' No migrations to roll back'
          return
        end

        path = migration_files.find { _1.include?(latest_version) }
        _, class_name = parse_filename(path)

        run_migration(path, class_name, direction: :down)
        SchemaMigration.remove!(latest_version)
        puts " #{class_name} (#{latest_version}) ... reverted"
      end

      private

      def run_migration(path, class_name, direction:)
        require File.expand_path(path)
        klass = Object.const_get(class_name)
        klass.new.migrate(direction)
      end

      def migration_files
        Dir["#{MIGRATIONS_DIR}/*.rb"].sort
      end

      # 例: '20260517000000_create_posts.rb' → ['20260517000000', 'CreatePosts']
      def parse_filename(path)
        basename = File.basename(path, '.rb')
        version, name_part = basename.split('_', 2)
        [version, name_part.camelize]
      end
    end
  end
end
