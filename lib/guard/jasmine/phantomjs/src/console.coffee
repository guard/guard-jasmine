# Simplified console logger replacement.
#
class Console

  # Construct the console wrapper and attach
  # the log methods.
  #
  constructor: (console) ->
    log = console.log

    console.log = (args...) ->
      log.call console, Console.format(args...)

    console.info = (args...) ->
      log.call console, "INFO: #{ Console.format(args...) }"

    console.warn = (args...) ->
      log.call console, "WARN: #{ Console.format(args...) }"

    console.error = (args...) ->
      log.call console, "ERROR: #{ Console.format(args...) }"

    console.debug = (args...) ->
      log.call console, "DEBUG: #{ Console.format(args...) }"

  @MAX_OBJECT_DEPTH: 2

  # Format the console arguments. This parses the known
  # % placeholder with the object value and/or concatenates
  # the arguments.
  #
  # @param [Array] args the log arguments
  #
  @format: (args...) ->
    result = []

    if typeof args[0] is 'string' and /%[sdifo]/gi.test args[0]
      arg = args.shift()
      result.push arg.replace /%[sdifo]/gi, (str) => Console.inspect args.shift(), str

    result.push Console.inspect arg for arg in args
    result.join ' '

  # Inspect a log object and return a string representation.
  #
  # @param [Object] object the object to inspect
  # @param [String] type the format type
  # @return [String] a string representation
  #
  @inspect: (object, type) ->
    switch type
      when '%s'
        result = String(object)
        result = match[1] if match = /'(.*)'/.exec result

      when '%d', '%i'
        result = parseInt object

      when '%f'
        result = parseFloat object

      else
        type = Object::toString.call(object).slice 8, -1

        if type is 'Object' and object.toJSON
          result = Console.pp object.toJSON()

        else if type is 'Object' and object.toString and object.toString() isnt '[object Object]'
          result = Console.pp object.toString()
          result = match[1] if match = /'(.*)'/.exec result

        else if type is 'String'
          result = String(object)
          result = match[1] if match = /'(.*)'/.exec result

        else
          result = Console.pp object

    result

  # Pretty print an object
  #
  # @param [Object] object the object to inspect
  # @param [Number] depth the object depth
  # @return [String] a string representation
  #
  @pp: (object, depth = 0) ->
    type = Object::toString.call(object).slice 8, -1
    result = ''

    switch type
      when 'Undefined', 'Null'
        result += type.toLowerCase()

      when 'Boolean', 'Number', 'Date'
        result += object.toString()

      when 'String'
        result += "'#{ object.toString() }'"

      when 'Array'
        if object.length > 0
          result += '['

          for value in object
            if depth < Console.MAX_OBJECT_DEPTH or Object::toString.call(value).slice(8, -1) isnt 'Object'
              result += "#{ Console.pp value, depth + 1 }, "
            else
              result += "[Object], "

          result = result.slice(0, -2)
          result += ']'
        else
          result += '[]'

      when 'Object'
        if object.jquery
          if object.length > 0
            result += '['

            object.each -> result += jQuery(@).html()

            result += ']'
          else
            result += '[]'

        else if Object.keys(object).length > 0
          result += '{ '

          for key, value of object
            if depth < Console.MAX_OBJECT_DEPTH or Object::toString.call(value).slice(8, -1) isnt 'Object'
              result += "#{ key }: #{ Console.pp value, depth + 1 }, " if object.hasOwnProperty key
            else
              result += "#{ key }: [Object], "

          result = result.slice(0, -2)
          result += ' }'
        else
          result += '{}'

      when 'Function'
        result += '[Function]'

    result

if typeof module isnt 'undefined' and module.exports
  module.exports = Console if module
else
  new Console(window.console) if window
