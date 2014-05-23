(function() {
  var exitSuccessfully, jasmineAvailable, options, page, reportError, reporterMissing, reporterReady, specsDone, specsTimedout, waitFor;

  options = {
    url: phantom.args[0] || 'http://127.0.0.1:3000/jasmine',
    timeout: parseInt(phantom.args[1] || 10000)
  };

  page = require('webpage').create();

  page.onError = function(message, trace) {
    return reportError("Javascript error encountered on Jasmine test page: " + message, trace);
  };

  page.onInitialized = function() {
    page.injectJs('guard-reporter.js');
    return page.evaluate(function() {
      return window.onload = function() {
        window.reporter = new GuardReporter();
        return window.jasmine.getEnv().addReporter(window.reporter);
      };
    });
  };

  page.onLoadFinished = function(status) {
    if (status !== 'success') {
      return reportError("Unable to access Jasmine specs at " + options.url + ", page returned status: " + status);
    } else {
      return waitFor(reporterReady, jasmineAvailable, options.timeout, reporterMissing);
    }
  };

  page.open(options.url);

  reporterReady = function() {
    return page.evaluate(function() {
      return window.jasmine && window.reporter;
    });
  };

  jasmineAvailable = function() {
    return waitFor(specsDone, exitSuccessfully, options.timeout, specsTimedout);
  };

  reporterMissing = function() {
    var text;
    text = page.evaluate(function() {
      var _ref;
      return (_ref = document.getElementsByTagName('body')[0]) != null ? _ref.innerText : void 0;
    });
    return reportError("The reporter is not available!\nPerhaps the url ( " + options.url + " ) is incorrect?\n\n" + text);
  };

  specsDone = function() {
    var result;
    return result = page.evaluate(function() {
      return window.reporter.resultComplete;
    });
  };

  exitSuccessfully = function() {
    var results;
    results = page.evaluate(function() {
      return window.reporter.results();
    });
    console.log(JSON.stringify(results));
    return phantom.exit();
  };

  specsTimedout = function() {
    var text;
    text = page.evaluate(function() {
      var _ref;
      return (_ref = document.getElementsByTagName('body')[0]) != null ? _ref.innerText : void 0;
    });
    return reportError("Timeout waiting for the Jasmine test results!\n\n" + text);
  };

  waitFor = function(test, ready, timeout, timeoutFunction) {
    var condition, interval, start, wait;
    if (timeout == null) {
      timeout = 10000;
    }
    condition = false;
    interval = void 0;
    start = Date.now(0);
    wait = function() {
      if (!condition && (Date.now() - start < timeout)) {
        return condition = test();
      } else {
        clearInterval(interval);
        if (condition) {
          return ready();
        } else {
          return timeoutFunction();
        }
      }
    };
    return interval = setInterval(wait, 250);
  };

  reportError = function(msg, trace) {
    var err;
    if (trace == null) {
      trace = [];
    }
    if (0 === trace.length) {
      err = new Error();
      trace = err.stack;
    }
    console.log(JSON.stringify({
      error: msg,
      trace: trace
    }));
    return phantom.exit(1);
  };

}).call(this);
