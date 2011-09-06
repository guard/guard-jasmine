module Guard
  class Jasmine
    module Formatter
      class << self

        def info(message, options={ })
          ::Guard::UI.info(message, options)
        end

        def debug(message, options={})
          ::Guard::UI.debug(message, options)
        end

        def error(message, options={})
          ::Guard::UI.error(color(message, ';31'), options)
        end

        def success(message, options={})
          ::Guard::UI.info(color(message, ';32'), options)
        end

        def notify(message, options={})
          ::Guard::Notifier.notify(message, options)
        end

        private

        def color(text, color_code)
          ::Guard::UI.send(:color_enabled?) ? "\e[0#{color_code}m#{text}\e[0m" : text
        end

      end
    end
  end
end
