(function() {
  var currentSpecId, errors, fs, getXmlResults, jasmineAvailable, jasmineMissing, jasmineReady, logs, options, overloadPageEvaluate, page, replaceFunctionPlaceholders, resultsKey, setupWriteFileFunction, specsDone, specsReady, specsTimedout, waitFor;

  phantom.injectJs('lib/result.js');

  options = {
    url: phantom.args[0] || 'http://127.0.0.1:3000/jasmine',
    timeout: parseInt(phantom.args[1] || 10000),
    specdoc: phantom.args[2] || 'failure',
    focus: /true/i.test(phantom.args[3]),
    console: phantom.args[4] || 'failure',
    errors: phantom.args[5] || 'failure',
    junit: /true/i.test(phantom.args[6]),
    junit_consolidate: /true/i.test(phantom.args[7]),
    junit_save_path: phantom.args[8] || ''
  };

  page = require('webpage').create();

  currentSpecId = -1;

  logs = {};

  errors = {};

  resultsKey = "__jr" + Math.ceil(Math.random() * 1000000);

  fs = require("fs");

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
    var setupReporters;

    overloadPageEvaluate(page);
    setupWriteFileFunction(page, resultsKey, fs.separator);
    page.injectJs('lib/console.js');
    page.injectJs('lib/reporter.js');
    page.injectJs('lib/junit_reporter.js');
    setupReporters = function() {
      return window.onload = function() {
        window.onload = null;
        window.resultReceived = false;
        window.reporter = new ConsoleReporter();
        if (window.jasmine) {
          jasmine.getEnv().addReporter(new JUnitXmlReporter("%save_path%", "%consolidate%"));
          return jasmine.getEnv().addReporter(window.reporter);
        }
      };
    };
    return page.evaluate(setupReporters, {
      save_path: options.junit_save_path,
      consolidate: options.junit_consolidate
    });
  };

  getXmlResults = function(page, key) {
    var getWindowObj;

    getWindowObj = function() {
      return window["%resultsObj%"] || {};
    };
    return page.evaluate(getWindowObj, {
      resultsObj: key
    });
  };

  replaceFunctionPlaceholders = function(fn, replacements) {
    var match, p;

    if (replacements && typeof replacements === 'object') {
      fn = fn.toString();
      for (p in replacements) {
        if (replacements.hasOwnProperty(p)) {
          match = new RegExp("%" + p + "%", "g");
          while (true) {
            fn = fn.replace(match, replacements[p]);
            if (fn.indexOf(match) === -1) {
              break;
            }
          }
        }
      }
    }
    return fn;
  };

  overloadPageEvaluate = function(page) {
    page._evaluate = page.evaluate;
    page.evaluate = function(fn, replacements) {
      return page._evaluate(replaceFunctionPlaceholders(fn, replacements));
    };
    return page;
  };

  setupWriteFileFunction = function(page, key, path_separator) {
    var saveData;

    saveData = function() {
      window["%resultsObj%"] = {};
      window.fs_path_separator = "%fs_path_separator%";
      return window.__phantom_writeFile = function(filename, text) {
        return window["%resultsObj%"][filename] = text;
      };
    };
    return page.evaluate(saveData, {
      resultsObj: key,
      fs_path_separator: path_separator
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
      var _ref;

      return (_ref = document.getElementsByTagName('body')[0]) != null ? _ref.innerText : void 0;
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
      var _ref;

      return (_ref = document.getElementsByTagName('body')[0]) != null ? _ref.innerText : void 0;
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
    var filename, output, xml_results;

    if (options.junit === true) {
      xml_results = getXmlResults(page, resultsKey);
      for (filename in xml_results) {
        if (xml_results.hasOwnProperty(filename) && (output = xml_results[filename]) && typeof output === 'string') {
          fs.write(filename, output, 'w');
        }
      }
    }
    return phantom.exit();
  };

  waitFor = function(test, ready, timeout, timeoutFunction) {
    var condition, interval, start, wait;

    if (timeout == null) {
      timeout = 10000;
    }
    start = Date.now();
    condition = false;
    interval = void 0;
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
