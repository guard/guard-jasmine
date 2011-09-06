require 'guard'
require 'guard/guard'
require 'guard/watcher'

module Guard
  class Jasmine < Guard

    autoload :Inspector, 'guard/Jasmine/inspector'
    autoload :Runner, 'guard/Jasmine/runner'

    def initialize(watchers = [], options = { })
      defaults = {
          :jasmine_url   => 'http://localhost:3000/jasmine',
          :phantomjs_bin => '/usr/local/bin/phantomjs',
          :notifications => true,
          :hide_success  => false,
      }
      super(watchers, defaults.merge(options))
    end

    def run_all
      run_on_change(Watcher.match_files(self, Dir.glob(File.join('spec', '**', '*.js(.coffee)?'))))
    end

    def run_on_change(paths)
      Runner.run(Inspector.clean(paths), options)
    end

  end
end
