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

          require File.expand_path(path)
          klass = Object.const_get(class_name)
          klass.new.migrate
          SchemaMigration.record!(version)
          puts " #{class_name} (#{version}) ... done"
          ran_any = true
        end

        puts ' No new migrations' unless ran_any
      end

      private

      # db/migrate/*.rb をファイル名でソートして返す
      # タイムスタンプの prefix で古い順からソートできるようになっている
      def migration_files
        Dir["#{MIGRATIONS_DIR}/*.rb"].sort
      end

      # 例: '20260517000000_create_posts.rb' → ['20260517000000', 'CreatePosts']
      # ファイル名のタイムスタンプとクラス名を分離する
      def parse_filename(path)
        basename = File.basename(path, '.rb')
        version, name_part = basename.split('_', 2)
        [version, name_part.camelize]
      end
    end
  end
end
