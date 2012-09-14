(function() {
  var ConsoleReporter,
    __hasProp = {}.hasOwnProperty;

  ConsoleReporter = (function() {

    function ConsoleReporter() {}

    ConsoleReporter.prototype.runnerResult = {
      passed: false,
      stats: {
        specs: 0,
        failures: 0,
        time: 0.0
      },
      suites: []
    };

    ConsoleReporter.prototype.specCount = 0;

    ConsoleReporter.prototype.currentSpecs = {};

    ConsoleReporter.prototype.nestedSuiteResults = {};

    ConsoleReporter.prototype.reportSpecStarting = function(spec) {
      return console.log("SPEC_START: " + spec.id);
    };

    ConsoleReporter.prototype.reportSpecResults = function(spec) {
      var messages, result, specResult, _base, _i, _len, _name, _ref;
      if (!spec.results().skipped) {
        specResult = {
          id: spec.id,
          description: '' + spec.description,
          passed: spec.results().failedCount === 0
        };
        if (spec.results().failedCount !== 0) {
          messages = [];
          _ref = spec.results().getItems();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            result = _ref[_i];
            messages.push(result.message);
          }
          if (messages.length !== 0) {
            specResult['messages'] = messages;
          }
        }
        this.specCount += 1;
        (_base = this.currentSpecs)[_name = spec.suite.id] || (_base[_name] = []);
        return this.currentSpecs[spec.suite.id].push(specResult);
      }
    };

    ConsoleReporter.prototype.reportSuiteResults = function(suite) {
      var parent, suiteResult, _base, _ref;
      if (!suite.results().skipped) {
        suiteResult = {
          id: suite.id,
          parent: (_ref = suite.parentSuite) != null ? _ref.id : void 0,
          description: '' + suite.description,
          passed: suite.results().failedCount === 0,
          specs: this.currentSpecs[suite.id] || [],
          suites: []
        };
        if (suite.parentSuite != null) {
          parent = suite.parentSuite.id;
          (_base = this.nestedSuiteResults)[parent] || (_base[parent] = []);
          return this.nestedSuiteResults[parent].push(suiteResult);
        } else {
          this.addNestedSuites(suiteResult);
          this.removeEmptySuites(suiteResult);
          if (suiteResult.specs.length !== 0 || suiteResult.suites.length !== 0) {
            return this.runnerResult.suites.push(suiteResult);
          }
        }
      }
    };

    ConsoleReporter.prototype.reportRunnerResults = function(runner) {
      var end, executedLoc, file, fileLoc, lines, runtime, totalExecutedLoc, totalLoc, _ref;
      runtime = (new Date().getTime() - this.startTime) / 1000;
      this.runnerResult['passed'] = runner.results().failedCount === 0;
      this.runnerResult['stats'] = {
        specs: this.specCount,
        failures: runner.results().failedCount,
        time: runtime
      };
      if (window._$jscoverage != null) {
        this.runnerResult['coverage'] = {};
        totalLoc = 0;
        totalExecutedLoc = 0;
        _ref = window._$jscoverage;
        for (file in _ref) {
          if (!__hasProp.call(_ref, file)) continue;
          lines = window._$jscoverage[file];
          fileLoc = lines.filter(function(line) {
            return line != null;
          }).length;
          totalLoc += fileLoc;
          executedLoc = lines.filter(function(line) {
            return (line != null) && line > 0;
          }).length;
          totalExecutedLoc += executedLoc;
          this.runnerResult['coverage'][file] = (executedLoc / fileLoc) * 100;
        }
        this.runnerResult['coverage']['total'] = (totalExecutedLoc / totalLoc) * 100;
      }
      end = function() {
        return console.log("RUNNER_END");
      };
      return setTimeout(end, 10);
    };

    ConsoleReporter.prototype.reportRunnerStarting = function(runner) {
      return this.startTime = new Date().getTime();
    };

    ConsoleReporter.prototype.addNestedSuites = function(suiteResult) {
      var suite, _i, _len, _ref, _results;
      if (this.nestedSuiteResults[suiteResult.id]) {
        _ref = this.nestedSuiteResults[suiteResult.id];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          suite = _ref[_i];
          this.addNestedSuites(suite);
          _results.push(suiteResult.suites.push(suite));
        }
        return _results;
      }
    };

    ConsoleReporter.prototype.removeEmptySuites = function(suiteResult) {
      var suite, suites, _i, _len, _ref;
      suites = [];
      _ref = suiteResult.suites;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        suite = _ref[_i];
        this.removeEmptySuites(suite);
        if (suite.suites.length !== 0 || suite.specs.length !== 0) {
          suites.push(suite);
        }
      }
      return suiteResult.suites = suites;
    };

    ConsoleReporter.prototype.log = function(message) {};

    return ConsoleReporter;

  })();

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = ConsoleReporter;
  } else {
    window.ConsoleReporter = ConsoleReporter;
  }

}).call(this);
