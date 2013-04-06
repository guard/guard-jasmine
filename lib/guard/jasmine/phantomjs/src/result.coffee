# Combines various information into the final result set
# that will be outputted to the console.
#
class Result

  # Construct the result parser
  #
  constructor: (@result, @logs = {}, @errors = {}, @options = {}) ->

  # Add captured log statements to the result
  #
  # @param [Object] suite the suite result
  # @return [Object] the suite
  #
  addLogs: (suite) ->
    suite.suites = for s in suite.suites
      @addLogs(s)

    if suite.specs
      suite.specs = for spec in suite.specs
        if @options.console is 'always' || (@options.console is 'failure' && !spec.passed)
          id = Number(spec['id'])
          spec.logs = @logs[id] if @logs[id] && @logs[id].length isnt 0

        spec

    suite

  # Add captured errors to the result
  #
  # @param [Object] suite the suite result
  # @return [Object] the suite
  #
  addErrors: (suite) ->
    suite.suites = for s in suite.suites
      @addErrors(s)

    if suite.specs
      suite.specs = for spec in suite.specs
        if @options.errors is 'always' || (@options.errors is 'failure' && !spec.passed)
          id = Number(spec['id'])
          spec.errors = @errors[id] if @errors[id] && @errors[id].length isnt 0

        spec

    suite

  addGlobalError: (suite) ->
    noSuites = !suite.suites || suite.suites.length == 0
    noSpecs = !suite.specs || suite.specs.length == 0
    globalErrors = @errors[-1] && @errors[-1].length != 0

    if noSuites && noSpecs && globalErrors
      err = @errors[-1][0]
      errMsg = [ err.msg ]
      for b in err.trace
        errMsg.push "\n  #{b.file}:#{b.line} #{b.function}"
      suite.error = errMsg.join("")
      suite.passed = false

  # Clean unnecessary properties from the result
  #
  # @param [Object] suite the suite result
  # @return [Object] the cleaned suite
  #
  cleanResult: (suite) ->
    suite.suites = for s in suite.suites
      @cleanResult(s)

    if suite.specs
      delete spec['id'] for spec in suite.specs

    delete suite['id']
    delete suite['parent']

    suite

  # Processes the collected results and returns
  # a single result object.
  #
  # @return [Object] the Jasmine result
  #
  process: ->
    @addLogs(@result) if @options.console isnt 'never'
    if @options.errors isnt 'never'
      @addErrors(@result)
      @addGlobalError(@result)
    @cleanResult(@result)

    @result

if typeof module isnt 'undefined' and module.exports
  module.exports = Result if module
else
  window.Result = Result if window
