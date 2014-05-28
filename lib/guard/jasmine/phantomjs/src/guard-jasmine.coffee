# Set default values
options =
  url: phantom.args[0] || 'http://127.0.0.1:3000/jasmine'
  timeout: parseInt(phantom.args[1] || 10000)

# Create the web page.
page = require('webpage').create()

# Catch JavaScript errors
# abort the request and return the error
page.onError = (message, trace) ->
    reportError "Javascript error encountered on Jasmine test page: #{ message }", trace

# Once the page is initialized, setup the script for
# the GuardReporter class
page.onInitialized = ->
    page.injectJs 'guard-reporter.js'
    page.evaluate ->
        window.onload = ->
            window.reporter =  new GuardReporter()
            window.jasmine.getEnv().addReporter(window.reporter) if window.jasmine

# Once the page is finished loading
page.onLoadFinished = (status)->
    if status isnt 'success'
        reportError "Unable to access Jasmine specs at #{ options.url }, page returned status: #{status}"
    else
        waitFor reporterReady, jasmineAvailable, options.timeout, reporterMissing

# Open web page, which will kick off the Jasmine test runner
page.open options.url

# Test if Jasmine and guard has been loaded
reporterReady = ->
    page.evaluate ->
        window.jasmine && window.reporter

# Start specs after they are have been loaded
jasmineAvailable = ->
    waitFor specsDone, exitSuccessfully, options.timeout, specsTimedout

# Error message for when jasmine never loaded asynchronously
reporterMissing = ->
  text = page.evaluate -> document.getElementsByTagName('body')[0]?.innerText
  reportError """
            The reporter is not available!
            Perhaps the url ( #{ options.url } ) is incorrect?

            #{ text }
            """

# tests if the resultComplete flag is set on the reporter
specsDone = ->
    result = page.evaluate ->
        window.reporter.resultComplete

# We should end up here.  Logs the results as JSON and exits
exitSuccessfully = ->
    results  = page.evaluate -> window.reporter.results()
    console.log JSON.stringify( results )
    phantom.exit()


# Error message for when specs time out
specsTimedout = ->
  text = page.evaluate -> document.getElementsByTagName('body')[0]?.innerText
  reportError """
            Timeout waiting for the Jasmine test results!

            #{ text }
            """

# Wait until the test condition is true or a timeout occurs.
#
# @param [Function] test the test that returns true if condition is met
# @param [Function] ready the action when the condition is fulfilled
# @param [Number] timeout the max amount of time to wait in milliseconds
#
waitFor = (test, ready, timeout = 10000, timeoutFunction)->
    condition = false
    interval = undefined
    start = Date.now(0)
    wait = ->
        if !condition && (Date.now() - start < timeout)
            condition = test()
        else
          clearInterval interval
          if condition
              ready()
          else
              timeoutFunction()
    interval = setInterval( wait, 250 )

# Logs the error to the console as JSON and exits with status '1'
reportError = (msg, trace=[])->
    if 0 == trace.length
        err = new Error();
        trace = err.stack
    console.log JSON.stringify({ error: msg, trace: trace })
    phantom.exit(1)
