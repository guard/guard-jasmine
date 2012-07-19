# Jasmine Reporter that logs reporter steps
# and results to the console.
#
class ConsoleReporter

  runnerResult: {
    passed: false
    stats: {
      specs: 0
      failures: 0
      time: 0.0
    }
    suites: []
  }

  specCount: 0
  currentSpecs: {}
  nestedSuiteResults: {}

  # Report the start of a spec.
  #
  # @param spec [jasmine.Spec] the spec
  #
  reportSpecStarting: (spec) ->
    console.log "SPEC_START: #{ spec.id }"

  # Report results from a spec.
  #
  # @param spec [jasmine.Spec] the spec
  #
  reportSpecResults: (spec) ->
    unless spec.results().skipped
      specResult = {
        id: spec.id
        description: '' + spec.description
        passed: spec.results().failedCount is 0
      }

      if spec.results().failedCount isnt 0
        messages = []
        messages.push result.message for result in spec.results().getItems()
        specResult['messages'] = messages if messages.length isnt 0

      @specCount += 1
      @currentSpecs[spec.suite.id] or= []
      @currentSpecs[spec.suite.id].push specResult

  # Report results from a suite.
  #
  # @param suite [jasmine.Suite] the suite
  #
  reportSuiteResults: (suite) ->
    unless suite.results().skipped
      suiteResult = {
        id: suite.id
        parent: suite.parentSuite?.id
        description: '' + suite.description
        passed: suite.results().failedCount is 0
        specs: @currentSpecs[suite.id] || []
        suites: []
      }

      if suite.parentSuite?
        parent = suite.parentSuite.id
        @nestedSuiteResults[parent] or= []
        @nestedSuiteResults[parent].push suiteResult
      else
        @addNestedSuites suiteResult
        @removeEmptySuites suiteResult

        if suiteResult.specs.length isnt 0 || suiteResult.suites.length isnt 0
          @runnerResult.suites.push suiteResult

  # Report results from the runner.
  #
  # @param runner [jasmine.Runner] the runner
  #
  reportRunnerResults: (runner) ->
    runtime = (new Date().getTime() - @startTime) / 1000

    @runnerResult['passed'] = runner.results().failedCount is 0

    @runnerResult['stats'] = {
      specs: @specCount
      failures: runner.results().failedCount
      time: runtime
    }

    # Delay the end runner message, so that logs and errors can be retreived in between
    end = -> console.log "RUNNER_END"
    setTimeout end, 10

  # Report the start of the runner
  #
  # @param runner [jasmine.Runner] the runner
  #
  reportRunnerStarting: (runner) ->
    @startTime = new Date().getTime()

  # Add all nested suites that have previously
  # been processed.
  #
  # @param suiteResult [Object] the suite result
  #
  addNestedSuites: (suiteResult) ->
    if @nestedSuiteResults[suiteResult.id]
      for suite in @nestedSuiteResults[suiteResult.id]
        @addNestedSuites suite
        suiteResult.suites.push suite

  # Removes suites without child suites or specs.
  #
  # @param suiteResult [Object] the suite result
  #
  removeEmptySuites: (suiteResult) ->
    suites = []

    for suite in suiteResult.suites
      @removeEmptySuites suite

      suites.push suite if suite.suites.length isnt 0 || suite.specs.length isnt 0

    suiteResult.suites = suites

  # Log a message
  #
  # @param message [String] the log message
  #
  log: (message) ->


if typeof module isnt 'undefined' and module.exports
  module.exports = ConsoleReporter
else
  window.ConsoleReporter = ConsoleReporter
