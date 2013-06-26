(function() {
  var currentSpecId, errors, jasmineAvailable, jasmineMissing, jasmineReady, logs, options, page, specsDone, specsReady, specsTimedout, waitFor;

  phantom.injectJs('lib/result.js');

  options = {
    url: phantom.args[0] || 'http://127.0.0.1:3000/jasmine',
    timeout: parseInt(phantom.args[1] || 10000),
    specdoc: phantom.args[2] || 'failure',
    focus: /true/i.test(phantom.args[3]),
    console: phantom.args[4] || 'failure',
    errors: phantom.args[5] || 'failure'
  };

  page = require('webpage').create();

  currentSpecId = -1;

  logs = {};

  errors = {};

  page.onError = function(msg, trace) {
    if (currentSpecId) {
      errors[currentSpecId] || (errors[currentSpecId] = []);
      return errors[currentSpecId].push({
        msg: msg,
        trace: trace
      });
    }
  };

  page.onConsoleMessage = function(msg, line, source) {
    var result;

    if (/^RUNNER_END$/.test(msg)) {
      result = page.evaluate(function() {
        return window.reporter.runnerResult;
      });
      console.log(JSON.stringify(new Result(result, logs, errors, options).process()));
      return page.evaluate(function() {
        return window.resultReceived = true;
      });
    } else if (/^SPEC_START: (\d+)$/.test(msg)) {
      return currentSpecId = Number(RegExp.$1);
    } else {
      logs[currentSpecId] || (logs[currentSpecId] = []);
      return logs[currentSpecId].push(msg);
    }
  };

  page.onInitialized = function() {
    page.injectJs('lib/console.js');
    page.injectJs('lib/reporter.js');
    return page.evaluate(function() {
      return window.onload = function() {
        window.onload = null;
        window.resultReceived = false;
        window.reporter = new ConsoleReporter();
        if (window.jasmine) {
          return jasmine.getEnv().addReporter(window.reporter);
        }
      };
    });
  };

  page.open(options.url, function(status) {
    page.onLoadFinished = function() {};
    if (status !== 'success') {
      console.log(JSON.stringify({
        error: "Unable to access Jasmine specs at " + options.url
      }));
      return phantom.exit();
    } else {
      return waitFor(jasmineReady, jasmineAvailable, options.timeout, jasmineMissing);
    }
  });

  jasmineReady = function() {
    return page.evaluate(function() {
      return window.jasmine;
    });
  };

  jasmineAvailable = function() {
    return waitFor(specsReady, specsDone, options.timeout, specsTimedout);
  };

  jasmineMissing = function() {
    var error, text;

    text = page.evaluate(function() {
      return document.getElementsByTagName('body')[0].innerText;
    });
    if (text) {
      error = "The Jasmine reporter is not available!\n\n" + text;
      return console.log(JSON.stringify({
        error: error
      }));
    } else {
      return console.log(JSON.stringify({
        error: 'The Jasmine reporter is not available!'
      }));
    }
  };

  specsReady = function() {
    return page.evaluate(function() {
      return window.resultReceived;
    });
  };

  specsTimedout = function() {
    var error, text;

    text = page.evaluate(function() {
      return document.getElementsByTagName('body')[0].innerText;
    });
    if (text) {
      error = "Timeout waiting for the Jasmine test results!\n\n" + text;
      return console.log(JSON.stringify({
        error: error
      }));
    } else {
      return console.log(JSON.stringify({
        error: 'Timeout for the Jasmine test results!'
      }));
    }
  };

  specsDone = function() {
    return phantom.exit();
  };

  waitFor = function(test, ready, timeout, timeoutFunction) {
    var condition, interval, start, wait;

    if (timeout == null) {
      timeout = 10000;
    }
    start = Date.now();
    condition = false;
    wait = function() {
      if ((Date.now() - start < timeout) && !condition) {
        return condition = test();
      } else {
        clearInterval(interval);
        if (condition) {
          return ready();
        } else {
          timeoutFunction();
          return phantom.exit(1);
        }
      }
    };
    return interval = setInterval(wait, 250);
  };

}).call(this);
