(function() {
  var ConsoleCapture, GuardReporter, extendObject;

  extendObject = function(a, b) {
    var key, value;
    for (key in b) {
      value = b[key];
      if (b.hasOwnProperty(key)) {
        a[key] = value;
      }
    }
    return a;
  };

  ConsoleCapture = (function() {
    var level, _i, _len, _ref;

    ConsoleCapture.DOT_REPORTER_MATCH = /\[\d+m[F.]..0m/;

    ConsoleCapture.levels = ['log', 'info', 'warn', 'error', 'debug'];

    ConsoleCapture.original = console;

    ConsoleCapture.original_levels = {};

    _ref = ConsoleCapture.levels;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      level = _ref[_i];
      ConsoleCapture.original_levels[level] = console[level];
    }

    function ConsoleCapture() {
      var _j, _len1, _ref1;
      this.original = {};
      this.captured = [];
      _ref1 = ConsoleCapture.levels;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        level = _ref1[_j];
        this._reassign_level(level);
      }
    }

    ConsoleCapture.prototype.revert = function() {
      var _j, _len1, _ref1, _results;
      _ref1 = ConsoleCapture.levels;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        level = _ref1[_j];
        _results.push(ConsoleCapture.original[level] = ConsoleCapture.original_levels[level]);
      }
      return _results;
    };

    ConsoleCapture.prototype._reassign_level = function(level) {
      var my;
      my = this;
      return console[level] = function() {
        var args, _ref1;
        args = Array.prototype.slice.call(arguments, 0);
        if ((_ref1 = args[0]) != null ? _ref1.match(ConsoleCapture.DOT_REPORTER_MATCH) : void 0) {
          return;
        }
        my.captured.push([level].concat(args));
        return ConsoleCapture.original_levels[level].apply(ConsoleCapture.original, arguments);
      };
    };

    return ConsoleCapture;

  })();

  GuardReporter = (function() {
    function GuardReporter() {}

    GuardReporter.STACK_MATCHER = new RegExp("__spec__\/(.*):([0-9]+)", "g");

    GuardReporter.prototype.jasmineStarted = function() {
      this.console = new ConsoleCapture();
      this.startedAt = Date.now();
      this.currentSuite = {
        suites: []
      };
      return this.stack = [this.currentSuite];
    };

    GuardReporter.prototype.suiteStarted = function(suite) {
      suite = extendObject({
        specs: [],
        suites: []
      }, suite);
      this.currentSuite.suites.push(suite);
      this.currentSuite = suite;
      return this.stack.push(suite);
    };

    GuardReporter.prototype.suiteDone = function(suite) {
      this.stack.pop();
      return this.currentSuite = this.stack[this.stack.length - 1];
    };

    GuardReporter.prototype.jasmineDone = function() {
      return this.resultComplete = true;
    };

    GuardReporter.prototype.specDone = function(spec) {
      var error, failure, match, _i, _len, _ref;
      this.resultReceived = true;
      spec = extendObject({
        logs: this.console.captured,
        errors: [],
        passed: 'passed' === spec.status
      }, spec);
      _ref = spec.failedExpectations;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        failure = _ref[_i];
        error = extendObject({
          trace: []
        }, failure);
        while (match = GuardReporter.STACK_MATCHER.exec(failure.stack)) {
          error.trace.push({
            file: match[1],
            line: parseInt(match[2])
          });
        }
        delete error.stack;
        spec.errors.push(error);
      }
      delete spec.failedExpectations;
      this.currentSuite.specs.push(spec);
      this.resetConsoleLog();
      return spec;
    };

    GuardReporter.prototype.resetConsoleLog = function() {
      this.console.revert();
      return this.console = new ConsoleCapture;
    };

    GuardReporter.prototype.eachSuite = function(suite) {
      var suites, _i, _len, _ref;
      suites = [].concat(suite.suites);
      _ref = suite.suites;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        suite = _ref[_i];
        suites = suites.concat(this.eachSuite(suite));
      }
      return suites;
    };

    GuardReporter.prototype.results = function() {
      var failure_count, spec, spec_count, suite, _i, _j, _len, _len1, _ref, _ref1;
      spec_count = 0;
      failure_count = 0;
      _ref = this.eachSuite(this.stack[0]);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        suite = _ref[_i];
        spec_count += suite.specs.length;
        _ref1 = suite.specs;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          spec = _ref1[_j];
          if (!spec.passed) {
            failure_count += 1;
          }
        }
      }
      return {
        stats: {
          specs: spec_count,
          failures: failure_count,
          time: (Date.now() - this.startedAt) / 1000
        },
        suites: this.stack[0].suites
      };
    };

    return GuardReporter;

  })();

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = GuardReporter;
  } else {
    window.GuardReporter = GuardReporter;
  }

}).call(this);
