##
# Wait until the test condition is true or a timeout occurs. Useful for waiting
# on a server response or for a ui change (fadeIn, etc.) to occur.
#
# @param testFx javascript condition that evaluates to a boolean,
# it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
# as a callback function.
# @param onReady what to do when testFx condition is fulfilled,
# it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
# as a callback function.
# @param timeOutMillis the max amount of time to wait. If not specified, 3 sec is used.
##
waitFor = (testFx, onReady, timeOutMillis=3000) ->
  start = new Date().getTime()
  condition = false
  f = ->
    if (new Date().getTime() - start < timeOutMillis) and not condition
      # If not time-out yet and condition not yet fulfilled
      condition = (if typeof testFx is 'string' then eval testFx else testFx()) #< defensive code
    else
      if not condition
        # If condition still not fulfilled (timeout but condition is 'false')
        console.log JSON.stringify { error: "Timeout requesting Jasmine test runner!" }
        phantom.exit(1)
      else
        # Condition fulfilled (timeout and/or condition is 'true')
        if typeof onReady is 'string' then eval onReady else onReady() #< Do what it's supposed to do once the condition is fulfilled
        clearInterval interval #< Stop this interval

  interval = setInterval f, 100 #< repeat check every 100ms

if phantom.args.length isnt 1
  console.log JSON.stringify { error: "Wrong usage of PhantomJS script!" }
  phantom.exit()

page = new WebPage()
page.onConsoleMessage = (msg) -> console.log msg

url = phantom.args[0]

page.open url, (status) ->
  if status isnt 'success'
    console.log JSON.stringify { error: "Unable to access Jasmine specs at #{ url }" }
    phantom.exit()

  else
    waitFor ->
      page.evaluate ->
        if document.body.querySelector '.finished-at' then true else false
    , ->
        page.evaluate ->
          result = {
            suites: []
          }

          # Extract runner stats from the HTML
          stats = /(\d+) specs, (\d+) failures? in (\d+.\d+)s/.exec document.body.querySelector('.description').innerText
          result['stats'] = {
            specs: parseInt stats[1]
            failures: parseInt stats[2]
            time: parseFloat stats[3]
          }

          # Extract failed suites
          for failedSuite in document.body.querySelectorAll 'div.jasmine_reporter > div.suite.failed'
            description = failedSuite.querySelector('a.description')
            suite = {
              description: description.innerText
              filter: description.getAttribute('href')
              specs: []
            }

            for failedSpec in failedSuite.querySelectorAll 'div.spec.failed'
              spec = {
                description: failedSpec.querySelector('a.description').getAttribute 'title'
                error_message: failedSpec.querySelector('div.messages div.resultMessage').innerText
              }
              suite['specs'].push spec

            result['suites'].push suite

          console.log JSON.stringify result, undefined, 2

        phantom.exit()
