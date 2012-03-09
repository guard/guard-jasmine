# Simplified console logger rreplacement.
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
      when '%d', '%i'
        result = parseInt object
      when '%f'
        result = parseFloat object
      else
        if Object::toString.call(object) is '[object Object]' and object.toJSON
          result = object.toJSON()
        else
          result = object

    result = match[1] if match = /'(.*)'/.exec result
    result

if typeof module isnt 'undefined' and module.exports
  module.exports = Console if module
else
  new Console(window.console) if window
