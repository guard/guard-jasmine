(function() {
  var ConsoleCapture, GuardReporter, extendObject, isFunction, isObject;

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

  isObject = function(obj) {
    var type;
    type = typeof obj;
    return type === 'function' || type === 'object' && !!obj;
  };

  isFunction = function(obj) {
    return typeof obj === 'function' || false;
  };

  ConsoleCapture = (function() {
    var i, len, level, ref;

    ConsoleCapture.DOT_REPORTER_MATCH = /\[\d+m[F.]..0m/;

    ConsoleCapture.levels = ['log', 'info', 'warn', 'error', 'debug'];

    ConsoleCapture.original = console;

    ConsoleCapture.original_levels = {};

    ref = ConsoleCapture.levels;
    for (i = 0, len = ref.length; i < len; i++) {
      level = ref[i];
      ConsoleCapture.original_levels[level] = console[level];
    }

    function ConsoleCapture() {
      var j, len1, ref1;
      this.original = {};
      this.captured = [];
      ref1 = ConsoleCapture.levels;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        level = ref1[j];
        this._reassign_level(level);
      }
    }

    ConsoleCapture.prototype.revert = function() {
      var j, len1, ref1, results;
      ref1 = ConsoleCapture.levels;
      results = [];
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        level = ref1[j];
        results.push(ConsoleCapture.original[level] = ConsoleCapture.original_levels[level]);
      }
      return results;
    };

    ConsoleCapture.prototype._reassign_level = function(level) {
      var my;
      my = this;
      return console[level] = function() {
        var args;
        args = Array.prototype.slice.call(arguments, 0);
        if (args[0] && args[0].toString && args[0].toString().match(ConsoleCapture.DOT_REPORTER_MATCH)) {
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

    GuardReporter.prototype.suiteDone = function(Suite) {
      this.stack.pop();
      return this.currentSuite = this.stack[this.stack.length - 1];
    };

    GuardReporter.prototype.jasmineDone = function() {
      return this.resultComplete = true;
    };

    GuardReporter.prototype.specDone = function(spec) {
      var error, failure, i, j, len, len1, match, ref, ref1, success;
      this.resultReceived = true;
      spec = extendObject({
        logs: this.console.captured,
        errors: []
      }, spec);
      ref = spec.failedExpectations || [];
      for (i = 0, len = ref.length; i < len; i++) {
        failure = ref[i];
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
        this.stringifyExpection(error);
        spec.errors.push(error);
      }
      delete spec.failedExpectations;
      ref1 = spec.passedExpectations || [];
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        success = ref1[j];
        this.stringifyExpection(success);
      }
      this.currentSuite.specs.push(spec);
      this.resetConsoleLog();
      return spec;
    };

    GuardReporter.prototype.stringifyExpection = function(expected) {
      var i, key, len, ref, results;
      ref = ['actual', 'expected'];
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        if (isFunction(expected[key])) {
          results.push(expected[key] = expected[key].name || "function");
        } else if (isObject(expected[key])) {
          results.push(expected[key] = expected[key].toString());
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    GuardReporter.prototype.resetConsoleLog = function() {
      this.console.revert();
      return this.console = new ConsoleCapture;
    };

    GuardReporter.prototype.eachSuite = function(suite) {
      var i, len, ref, suites;
      suites = [].concat(suite.suites);
      ref = suite.suites;
      for (i = 0, len = ref.length; i < len; i++) {
        suite = ref[i];
        suites = suites.concat(this.eachSuite(suite));
      }
      return suites;
    };

    GuardReporter.prototype.results = function() {
      var i, j, len, len1, ref, ref1, spec, stats, suite;
      stats = {
        time: (Date.now() - this.startedAt) / 1000,
        specs: 0,
        failed: 0,
        pending: 0,
        disabled: 0
      };
      ref = this.eachSuite(this.stack[0]);
      for (i = 0, len = ref.length; i < len; i++) {
        suite = ref[i];
        stats.specs += suite.specs.length;
        ref1 = suite.specs;
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          spec = ref1[j];
          if (void 0 !== stats[spec.status]) {
            stats[spec.status] += 1;
          }
        }
      }
      return {
        jasmine_version: typeof jasmine !== "undefined" && jasmine !== null ? jasmine.version : void 0,
        stats: stats,
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
