system = require('system');

#console.log system.args
# Set default values
options =
  url: system.args[1] || 'http://localhost:3000/jasmine'
  timeout: parseInt(system.args[2] || 10000)

# Create the web page.
page = require('webpage').create()

# Define fs to write files for custom reporters
fs = require('fs')

# Catch JavaScript errors
# abort the request and return the error
page.onError = (message, trace) ->
    reportError "Javascript error encountered on Jasmine test page: #{ message }", trace

page.onResourceError = (error)->
    page.reason = error.errorString
    page.reason_url = error.url

# Once the page is initialized, setup the script for
# the GuardReporter class
page.onInitialized = ->
    page.injectJs 'guard-reporter.js'
    injectReporter = (pathSeparator) ->
        window.onload = ->
            window.reporter = new GuardReporter()
            window.fs_path_separator = "#{pathSeparator}"
            window.__phantom_writeFile = (filename, text) ->
                window.callPhantom({event: 'writeFile', filename: filename, text: text})
            window.jasmine.getEnv().addReporter(window.reporter) if window.jasmine
    page.evaluate injectReporter, fs.separator

# Once the page is finished loading
page.onLoadFinished = (status) ->
    if status isnt 'success'
        reportError "Unable to access Jasmine specs at #{page.reason_url}. #{page.reason}"
    else
        waitFor reporterReady, jasmineAvailable, options.timeout, reporterMissing

page.onCallback = (data) ->
    if data.event is 'writeFile'
        fs.write(data.filename, data.text, 'w')
    else
        console.log('unknown event callback: ' + data.event)

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

# Workaround for https://github.com/ariya/phantomjs/issues/12697 since
# it doesn't seem like there will be another 1.9.x release fixing this
phantomExit = (exitCode)->
    page.close()
    setTimeout( ->
        phantom.exit(exitCode)
    ,0)


# We should end up here.  Logs the results as JSON and exits
exitSuccessfully = ->
    results  = page.evaluate -> window.reporter.results()
    console.log JSON.stringify( results )
    phantomExit()

exitError = (message)->
    console.log JSON.stringify({error: message})
    phantomExit(1)


# Error message for when specs time out
specsTimedout = ->
    text = page.evaluate -> document.getElementsByTagName('body')[0]?.innerText
    reportError """
            Timeout waiting for the Jasmine test results!

            #{ text }
            """
    return phantomExit(1)

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
            try
                condition = test()
            catch e
                exitError(e)
        else
          clearInterval interval
          if condition
              ready()
          else
              timeoutFunction()
    interval = setInterval( wait, 250 )

# Logs the error to the console as JSON and exits with status '1'
hasLoggedError = false
reportError = (msg, trace=[])->
    return if hasLoggedError
    if 0 == trace.length
        err = new Error();
        trace = err.stack
    console.log JSON.stringify({ error: msg, trace: trace })
    hasLoggedError = true
    return phantomExit(1)
