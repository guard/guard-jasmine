(function() {
  var Console,
    __slice = [].slice;

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

    Console.MAX_OBJECT_DEPTH = 2;

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
          if (match = /'(.*)'/.exec(result)) {
            result = match[1];
          }
          break;
        case '%d':
        case '%i':
          result = parseInt(object);
          break;
        case '%f':
          result = parseFloat(object);
          break;
        default:
          type = Object.prototype.toString.call(object).slice(8, -1);
          if (type === 'Object' && object.toJSON) {
            result = Console.pp(object.toJSON());
          } else if (type === 'Object' && object.toString && object.toString() !== '[object Object]') {
            result = Console.pp(object.toString());
            if (match = /'(.*)'/.exec(result)) {
              result = match[1];
            }
          } else if (type === 'String') {
            result = String(object);
            if (match = /'(.*)'/.exec(result)) {
              result = match[1];
            }
          } else {
            result = Console.pp(object);
          }
      }
      return result;
    };

    Console.pp = function(object, depth) {
      var key, result, type, value, _i, _len;

      if (depth == null) {
        depth = 0;
      }
      type = Object.prototype.toString.call(object).slice(8, -1);
      result = '';
      switch (type) {
        case 'Undefined':
        case 'Null':
          result += type.toLowerCase();
          break;
        case 'Boolean':
        case 'Number':
        case 'Date':
          result += object.toString();
          break;
        case 'String':
          result += "'" + (object.toString()) + "'";
          break;
        case 'Array':
          if (object.length > 0) {
            result += '[';
            for (_i = 0, _len = object.length; _i < _len; _i++) {
              value = object[_i];
              if (depth < Console.MAX_OBJECT_DEPTH || Object.prototype.toString.call(value).slice(8, -1) !== 'Object') {
                result += "" + (Console.pp(value, depth + 1)) + ", ";
              } else {
                result += "[Object], ";
              }
            }
            result = result.slice(0, -2);
            result += ']';
          } else {
            result += '[]';
          }
          break;
        case 'Object':
          if (object.jquery) {
            if (object.length > 0) {
              result += '[';
              object.each(function() {
                return result += jQuery(this).html();
              });
              result += ']';
            } else {
              result += '[]';
            }
          } else if (Object.keys(object).length > 0) {
            result += '{ ';
            for (key in object) {
              value = object[key];
              if (depth < Console.MAX_OBJECT_DEPTH || Object.prototype.toString.call(value).slice(8, -1) !== 'Object') {
                if (object.hasOwnProperty(key)) {
                  result += "" + key + ": " + (Console.pp(value, depth + 1)) + ", ";
                }
              } else {
                result += "" + key + ": [Object], ";
              }
            }
            result = result.slice(0, -2);
            result += ' }';
          } else {
            result += '{}';
          }
          break;
        case 'Function':
          result += '[Function]';
      }
      return result;
    };

    return Console;

  })();

  if (typeof module !== 'undefined' && module.exports) {
    if (module) {
      module.exports = Console;
    }
  } else {
    if (window) {
      new Console(window.console);
    }
  }

}).call(this);
