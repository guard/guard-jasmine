# Wait until the test condition is true or a timeout occurs.
#
# @param [Function] testFx the condition that evaluates to a boolean
# @param [Function] onReady the action when the condition is fulfilled
# @param [Number] timeOutMillis the max amount of time to wait
#
waitFor = (testFx, onReady, timeOutMillis=3000) ->
  start = new Date().getTime()
  condition = false
  wait = ->
    if (new Date().getTime() - start < timeOutMillis) and not condition
      condition = (if typeof testFx is 'string' then eval testFx else testFx())
    else
      if not condition
        console.log JSON.stringify { error: "Timeout requesting Jasmine test runner!" }
        phantom.exit(1)
      else
        if typeof onReady is 'string' then eval onReady else onReady()
        clearInterval interval

  interval = setInterval wait, 100

# Check arguments of the script.
#
if phantom.args.length isnt 1
  console.log JSON.stringify { error: "Wrong usage of PhantomJS script!" }
  phantom.exit()
else
  url = phantom.args[0]

page = new WebPage()

# Output the Jasmine test runner result as JSON object.
# Ignore all other calls to console.log
#
page.onConsoleMessage = (msg) ->
  console.log(RegExp.$1) if /^JasmineResult: ([\s\S]*)$/.test(msg)

# Open web page and run the Jasmine test runner
#
page.open url, (status) ->

  if status isnt 'success'

    console.log "JasmineResult: #{ JSON.stringify { error: "Unable to access Jasmine specs at #{ url }" } }"
    phantom.exit()

  else
    # Wait until the Jasmine test is run
    waitFor ->
      page.evaluate ->
        if document.body.querySelector '.finished-at' then true else false
    , ->
        # Jasmine test runner has finished, extract the result from the DOM
        page.evaluate ->

          # JSON response to Guard::Jasmine
          result = {
            suites: []
          }

          # Extract runner stats from the HTML
          stats = /(\d+) specs, (\d+) failures? in (\d+.\d+)s/.exec document.body.querySelector('.description').innerText

          # Add stats to the result
          result['stats'] = {
            specs: parseInt stats[1]
            failures: parseInt stats[2]
            time: parseFloat stats[3]
          }

          # Extract failed suites
          for failedSuite in document.body.querySelectorAll 'div.jasmine_reporter > div.suite.failed'
            description = failedSuite.querySelector('a.description')

            # Add suite information to the result
            suite = {
              description: description.innerText
              filter: description.getAttribute('href')
              specs: []
            }

            # Collect information about each **failing** spec
            for failedSpec in failedSuite.querySelectorAll 'div.spec.failed'
              spec = {
                description: failedSpec.querySelector('a.description').getAttribute 'title'
                error_message: failedSpec.querySelector('div.messages div.resultMessage').innerText
              }
              suite['specs'].push spec

            result['suites'].push suite

          # Write result as JSON string that is parsed by Guard::Jasmine
          console.log "JasmineResult: #{ JSON.stringify result, undefined, 2 }"

        phantom.exit()
