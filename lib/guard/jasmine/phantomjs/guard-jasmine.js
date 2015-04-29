(function() {
  var exitError, exitSuccessfully, hasLoggedError, jasmineAvailable, options, page, phantomExit, reportError, reporterMissing, reporterReady, specsDone, specsTimedout, system, waitFor;

  system = require('system');

  options = {
    url: system.args[1] || 'http://localhost:3000/jasmine',
    timeout: parseInt(system.args[2] || 10000)
  };

  page = require('webpage').create();

  page.onError = function(message, trace) {
    return reportError("Javascript error encountered on Jasmine test page: " + message, trace);
  };

  page.onResourceError = function(error) {
    page.reason = error.errorString;
    return page.reason_url = error.url;
  };

  page.onInitialized = function() {
    page.injectJs('guard-reporter.js');
    return page.evaluate(function() {
      return window.onload = function() {
        window.reporter = new GuardReporter();
        if (window.jasmine) {
          return window.jasmine.getEnv().addReporter(window.reporter);
        }
      };
    });
  };

  page.onLoadFinished = function(status) {
    if (status !== 'success') {
      return reportError("Unable to access Jasmine specs at " + page.reason_url + ". " + page.reason);
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
      var ref;
      return (ref = document.getElementsByTagName('body')[0]) != null ? ref.innerText : void 0;
    });
    return reportError("The reporter is not available!\nPerhaps the url ( " + options.url + " ) is incorrect?\n\n" + text);
  };

  specsDone = function() {
    var result;
    return result = page.evaluate(function() {
      return window.reporter.resultComplete;
    });
  };

  phantomExit = function(exitCode) {
    page.close();
    return setTimeout(function() {
      return phantom.exit(exitCode);
    }, 0);
  };

  exitSuccessfully = function() {
    var results;
    results = page.evaluate(function() {
      return window.reporter.results();
    });
    console.log(JSON.stringify(results));
    return phantomExit();
  };

  exitError = function(message) {
    console.log(JSON.stringify({
      error: message
    }));
    return phantomExit(1);
  };

  specsTimedout = function() {
    var text;
    text = page.evaluate(function() {
      var ref;
      return (ref = document.getElementsByTagName('body')[0]) != null ? ref.innerText : void 0;
    });
    reportError("Timeout waiting for the Jasmine test results!\n\n" + text);
    return phantomExit(1);
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
      var e;
      if (!condition && (Date.now() - start < timeout)) {
        try {
          return condition = test();
        } catch (_error) {
          e = _error;
          return exitError(e);
        }
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

  hasLoggedError = false;

  reportError = function(msg, trace) {
    var err;
    if (trace == null) {
      trace = [];
    }
    if (hasLoggedError) {
      return;
    }
    if (0 === trace.length) {
      err = new Error();
      trace = err.stack;
    }
    console.log(JSON.stringify({
      error: msg,
      trace: trace
    }));
    hasLoggedError = true;
    return phantomExit(1);
  };

}).call(this);
