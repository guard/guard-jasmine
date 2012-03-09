# This file is the script that runs within PhantomJS, requests the Jasmine specs
# and waits until they are ready.

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
  if /^RUNNER_END$/.test(msg)
    result = page.evaluate -> window.reporter.runnerResult

    for suite in result.suites
      page.addLogs(suite)

    console.log JSON.stringify(result)

    page.evaluate -> window.resultReceived = true

  else if /^SPEC_START: (\d+)$/.test(msg)
    currentSpecId = Number(RegExp.$1)
    logs[currentSpecId] = []

  else
    logs[currentSpecId].push(msg) if currentSpecId isnt -1

# Initialize the page before the JavaScript is run.
#
page.onInitialized = ->
  page.injectJs 'lib/console.js'
  page.injectJs 'lib/reporter.js'

  page.evaluate ->
    # Attach the console reporter when the document is ready.
    window.onload = ->
      window.resultReceived = false
      window.reporter = new ConsoleReporter()
      jasmine.getEnv().addReporter(window.reporter)

# Open web page and run the Jasmine test runner
#
page.open url, (status) ->
  # Avoid that a failed iframe load breaks the runner, see https://github.com/netzpirat/guard-jasmine/pull/19
  page.onLoadFinished = ->

  if status isnt 'success'
    console.log JSON.stringify({ error: "Unable to access Jasmine specs at #{ url }" })
    phantom.exit()
  else
    done = -> phantom.exit()
    waitFor specsReady, done, timeout

# Test if the specs have finished.
#
specsReady = ->
  page.evaluate -> window.resultReceived

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
