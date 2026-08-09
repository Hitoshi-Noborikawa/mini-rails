# frozen_string_literal: true

module MiniRails
  class Autoloader
    # inflector を引数で渡せるようにしておく。
    # Zeitwerk も loader.inflector = ... で差し替えられるようにしており、loader 自体が特定の Inflector に依存しないためにしている。
    # （本家だと他の gem から利用することも考慮しているため）
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
          # .../app/models/human/ ディレクトリの場合
          # define_autoloads(.../app/models/human, Object.const_set(:Human, Module.new)) となる
          define_autoloads(abspath, namespace.const_set(cname(basename), Module.new))
        elsif basename.end_with?('.rb')
          # basename = 'post.rb' の場合
          # Object.autoload(:Post, '.../app/models/post.rb') となる
          namespace.autoload(cname(basename.delete_suffix('.rb')), abspath)
        end
      end
    end

    def cname(basename)
      @inflector.camelize(basename).to_sym
    end
  end
end
