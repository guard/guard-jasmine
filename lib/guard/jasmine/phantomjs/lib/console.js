(function() {
  var Console,
    __slice = Array.prototype.slice;

  Console = (function() {

    function Console(console) {
      var log;
      log = console.log;
      console.log = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return log.call(console, Console.format.apply(Console, args));
      };
      console.info = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return log.call(console, "INFO: " + (Console.format.apply(Console, args)));
      };
      console.warn = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return log.call(console, "WARN: " + (Console.format.apply(Console, args)));
      };
      console.error = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return log.call(console, "ERROR: " + (Console.format.apply(Console, args)));
      };
      console.debug = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return log.call(console, "DEBUG: " + (Console.format.apply(Console, args)));
      };
    }

    Console.format = function() {
      var arg, args, result, _i, _len,
        _this = this;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      result = [];
      if (typeof args[0] === 'string' && /%[sdifo]/gi.test(args[0])) {
        arg = args.shift();
        result.push(arg.replace(/%[sdifo]/gi, function(str) {
          return Console.inspect(args.shift(), str);
        }));
      }
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        arg = args[_i];
        result.push(Console.inspect(arg));
      }
      return result.join(' ');
    };

    Console.inspect = function(object, type) {
      var match, result;
      switch (type) {
        case '%s':
          result = String(object);
          break;
        case '%d':
        case '%i':
          result = parseInt(object);
          break;
        case '%f':
          result = parseFloat(object);
          break;
        default:
          if (Object.prototype.toString.call(object) === '[object Object]' && object.toJSON) {
            result = object.toJSON();
          } else {
            result = object;
          }
      }
      if (match = /'(.*)'/.exec(result)) result = match[1];
      return result;
    };

    return Console;

  })();

  if (typeof module !== 'undefined' && module.exports) {
    if (module) module.exports = Console;
  } else {
    if (window) new Console(window.console);
  }

}).call(this);
