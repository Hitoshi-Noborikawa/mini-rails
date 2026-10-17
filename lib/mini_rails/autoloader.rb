# frozen_string_literal: true

module MiniRails
  class Autoloader
    # The inflector can be passed in as an argument.
    # Zeitwerk likewise lets you swap it with loader.inflector = ..., so the loader doesn't depend on a specific Inflector.
    # (Zeitwerk is also meant to be used by other gems.)
    # https://github.com/fxn/zeitwerk/blob/fe92d109e290d875b95a002dd75c140a851b6baa/lib/zeitwerk/loader/config.rb#L14
    def initialize(inflector: MiniSupport::Inflector)
      @dirs = []
      @inflector = inflector
    end

    def push_dir(dir)
      @dirs << File.expand_path(dir)
    end

    def setup
      @dirs.each { |dir| define_autoloads(dir, Object) }
    end

    private

    def define_autoloads(dir, namespace)
      Dir.children(dir).sort.each do |basename|
        abspath = File.join(dir, basename)

        if File.directory?(abspath)
          # For the directory .../app/models/human/
          # define_autoloads(.../app/models/human, Object.const_set(:Human, Module.new))
          define_autoloads(abspath, namespace.const_set(cname(basename), Module.new))
        elsif basename.end_with?('.rb')
          # For basename = 'post.rb'
          # Object.autoload(:Post, '.../app/models/post.rb')
          namespace.autoload(cname(basename.delete_suffix('.rb')), abspath)
        end
      end
    end

    def cname(basename)
      @inflector.camelize(basename).to_sym
    end
  end
end
