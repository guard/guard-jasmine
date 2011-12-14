# This file is the script that runs within PhantomJS, requests the Jasmine specs
# and waits until they are ready.

# Wait until the test condition is true or a timeout occurs.
#
# @param [Function] test the test that returns true if condition is met
# @param [Function] ready the action when the condition is fulfilled
# @param [Number] timeout the max amount of time to wait in milliseconds
#
waitFor = (test, ready, timeout = 5000) ->
    start = new Date().getTime()
    condition = false

    wait = ->
      if (new Date().getTime() - start < timeout) and not condition
        condition = test()
      else
        if not condition
          text = page.evaluate -> document.getElementsByTagName('body')[0]?.innerText

          if text
            error = """
                    Timeout waiting for the Jasmine test results!

                    #{ text }
                    """
            console.log JSON.stringify({ error: error })
          else
            console.log JSON.stringify({ error: 'Timeout waiting for the Jasmine test results!' })

          phantom.exit(1)
        else
          ready()
          clearInterval interval

    interval = setInterval wait, 250

# Test if the specs have finished.
#
specsReady = ->
  page.evaluate -> window.resultReceived

#
# SCRIPT START
#

# Set default values
url = phantom.args[0] || 'http://127.0.0.1:3000/jasmine'
timeout = parseInt(phantom.args[1] || 5000)

# Create the web page.
#
page = require('webpage').create()

# Used to collect log messages for later assignment to the spec
#
currentSpecId = -1
logs = {}

# Add logs to the given suite
#
# @param suite [Object} the suite result
#
page.addLogs = (suite) ->
  for s in suite.suites
    arguments.callee(s) if s

  for spec in suite.specs
    id = Number(spec['id'])
    spec['logs'] = logs[id] if logs[id] && logs[id].length isnt 0
    delete spec['id']

  delete suite['id']
  delete suite['parent']

# Capture console.log output to add it to
# the result when specs have finished.
#
page.onConsoleMessage = (msg, line, source) ->
  if /^RUNNER_RESULT: ([\s\S]*)$/.test(msg)
    result = JSON.parse(RegExp.$1)

    for suite in result.suites
      page.addLogs(suite)

    console.log JSON.stringify(result, undefined, 2)
    page.evaluate -> window.resultReceived = true

  else if /^SPEC_START: (\d+)$/.test(msg)
    currentSpecId = Number(RegExp.$1)
    logs[currentSpecId] = []

  else
    logs[currentSpecId].push("#{ msg } in #{ source } (line #{ line })") if currentSpecId isnt -1

# Initialize the page before the JavaScript is run.
#
page.onInitialized = ->
  page.evaluate ->

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

      currentSpecs: []
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
            description: spec.description
            passed: spec.results().failedCount is 0
          }

          if spec.results().failedCount isnt 0
            messages = []
            messages.push result.message for result in spec.results().getItems()
            specResult['messages'] = messages if messages.length isnt 0

          @currentSpecs.push specResult

      # Report results from a suite.
      #
      # @param suite [jasmine.Suite] the suite
      #
      reportSuiteResults: (suite) ->
        unless suite.results().skipped
          suiteResult = {
            id: suite.id
            parent: suite.parentSuite?.id
            description: suite.description
            passed: suite.results().failedCount is 0
            specs: @currentSpecs
            suites: []
          }

          if suite.parentSuite?
            parent = suite.parentSuite.id
            @nestedSuiteResults[parent] = [] unless @nestedSuiteResults[parent]
            @nestedSuiteResults[parent].push suiteResult
          else
            @addNestedSuites suiteResult
            @removeEmptySuites suiteResult

            if suiteResult.specs.length isnt 0 || suiteResult.suites.length isnt 0
              @runnerResult.suites.push suiteResult

        @currentSpecs = []

      # Report results from the runner.
      #
      # @param runner [jasmine.Runner] the runner
      #
      reportRunnerResults: (runner) ->
        runtime = (new Date().getTime() - @startTime) / 1000

        @runnerResult['passed'] = runner.results().failedCount is 0

        @runnerResult['stats'] = {
          specs: runner.results().totalCount
          failures: runner.results().failedCount
          time: runtime
        }

        console.log "RUNNER_RESULT: #{ JSON.stringify(@runnerResult) }"

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

    # Attach the console reporter when the document is ready.
    #
    window.onload = ->
      window.resultReceived = false
      jasmine.getEnv().addReporter(new ConsoleReporter())

# Open web page and run the Jasmine test runner
#
page.open url, (status) ->
  page.onLoadFinished = ->
  if status isnt 'success'
    console.log JSON.stringify({ error: "Unable to access Jasmine specs at #{ url }" })
    phantom.exit()
  else
    done = -> phantom.exit()
    waitFor specsReady, done, timeout
