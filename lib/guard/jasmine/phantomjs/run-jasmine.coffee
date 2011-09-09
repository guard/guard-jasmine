# This file is the script that runs within PhantomJS and requests the Jasmine specs,
# waits until they are ready, extracts the result form the dom and outputs a JSON
# structure that is the parsed by Guard::Jasmine.
#
# This scripts needs the TrivialReporter to report the results.
#
# This file is inspired by the Jasmine runner that comes with the PhantomJS examples:
# https://github.com/ariya/phantomjs/blob/master/examples/run-jasmine.coffee, by https://github.com/Roejames12
#
# This file is licensed under the BSD license.

# Wait until the test condition is true or a timeout occurs.
#
# @param [Function] condition the condition that evaluates to a boolean
# @param [Function] ready the action when the condition is fulfilled
# @param [Number] timeout the max amount of time to wait
#
waitFor = (condition, ready, timeout = 3000) ->
  start = new Date().getTime()
  wait = ->
    if new Date().getTime() - start > timeout
      console.log JSON.stringify({ error: "Timeout requesting Jasmine test runner!" })
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

# Extract the data from a Jasmine TrivialReporter generated DOM
#
extractResult = ->
  page.evaluate ->
    stats = /(\d+) specs?, (\d+) failures? in (\d+.\d+)s/.exec(document.body.querySelector('.description').innerText)
    specs = parseInt stats[1]
    failures = parseInt stats[2]
    time = parseFloat stats[3]
    passed = failures is 0

    result = {
      passed: passed
      stats: {
        specs: specs
        failures: failures
        time: time
      }
      suites: []
    }

    for suite in document.body.querySelectorAll('div.jasmine_reporter > div.suite')
      description = suite.querySelector('a.description')
      suite_ = {
        description: description.innerText
        specs: []
      }

      for spec in suite.querySelectorAll('div.spec')
        status = spec.getAttribute('class').substring(5)
        if status isnt 'skipped'
          passed = status is 'passed'
          spec_ = {
            description: spec.querySelector('a.description').getAttribute 'title'
            passed: passed
          }
          spec_['error_message'] = spec.querySelector('div.resultMessage').innerText if not passed
          suite_['specs'].push spec_

      result['suites'].push suite_

    console.log "JSON_RESULT: #{ JSON.stringify(result, undefined, 2) }"

  phantom.exit()

# Check arguments of the script.
#
if phantom.args.length isnt 1
  console.log JSON.stringify({ error: "Wrong usage of PhantomJS script!" })
  phantom.exit()
else
  url = phantom.args[0]

page = new WebPage()

# Output the Jasmine test runner result as JSON object.
# Ignore all other calls to console.log that may come from the specs.
#
page.onConsoleMessage = (msg) ->
  console.log(RegExp.$1) if /^JSON_RESULT: ([\s\S]*)$/.test(msg)

# Open web page and run the Jasmine test runner
#
page.open url, (status) ->
  if status isnt 'success'
    console.log "JSON_RESULT: #{ JSON.stringify({ error: "Unable to access Jasmine specs at #{ url }" }) }"
    phantom.exit()
  else
    waitFor specsReady, extractResult
