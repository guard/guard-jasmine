# This file is the script that runs within PhantomJS, requests the Jasmine specs
# and waits until they are ready.
#
# A console reporter is injected into Jasmine to stream status messages as they occur.

# Wait until the test condition is true or a timeout occurs.
#
# @param [Function] condition the condition that evaluates to a boolean
# @param [Function] ready the action when the condition is fulfilled
# @param [Number] timeout the max amount of time to wait
#
waitFor = (condition, ready, timeout = 5000) ->
  start = new Date().getTime()
  wait = ->
    if new Date().getTime() - start > timeout
      console.log JSON.stringify({ error: 'Timeout requesting Jasmine test runner!' })
      phantom.exit(1)
    else
      if condition()
        ready()
        clearInterval interval

  interval = setInterval wait, 100

# Test if the specs have finished.
#
specsReady = ->
  page.evaluate -> if document.body.querySelector('.finished-at') then true else false

# Check arguments of the script.
#
if phantom.args.length isnt 1
  console.log JSON.stringify({ error: 'Wrong usage of PhantomJS script!' })
  phantom.exit()
else
  url = phantom.args[0]

# Create the web page.
#
page = require('webpage').create()

# Capture console.log output to wrap the output
# from the specs into a JSON message.
#
page.onConsoleMessage = (msg, line, source) ->
  console.log JSON.stringify({ log: msg, line: line, source: source })

# The console reporter sends its response as alert.
#
page.onAlert = (msg) -> console.log msg

# Initialize the page before the JavaScript is run.
#
page.onInitialized = ->
  page.evaluate ->

    # Jasmine Reporter that logs results through an alert.
    #
    class ConsoleReporter

      reportSpecResults: (spec) ->
        @report { spec: spec.description, failed: spec.results().failedCount, skiped: spec.results().skipped }

      reportSuiteResults: (suite) ->
        @report { suite: suite.getFullName(), failed: suite.results().failedCount, skiped: suite.results().skipped  }

      reportRunnerResults: (runner) ->
        @report { finish: runner.description, total: runner.results().totalCount, failed: runner.results().failedCount }

      reportRunnerStarting: (runner) ->
      reportSpecStarting: (spec) ->
      log: (str) ->

      report: (response) ->
        alert JSON.stringify(response)

    # Attach the console reporter when the document is ready.
    #
    window.onload = ->
      jasmine.getEnv().addReporter(new ConsoleReporter())

# Open web page and run the Jasmine test runner
#
page.open url, (status) ->
  if status isnt 'success'
    console.log JSON.stringify({ error: "Unable to access Jasmine specs at #{ url }" })
    phantom.exit()
  else
    waitFor specsReady, -> phantom.exit()

