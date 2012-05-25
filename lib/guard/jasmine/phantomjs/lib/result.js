(function() {
  var Result;

  Result = (function() {

    function Result(result, logs, errors, options) {
      this.result = result;
      this.logs = logs != null ? logs : {};
      this.errors = errors != null ? errors : {};
      this.options = options != null ? options : {};
    }

    Result.prototype.addLogs = function(suite) {
      var id, s, spec;
      suite.suites = (function() {
        var _i, _len, _ref, _results;
        _ref = suite.suites;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          _results.push(this.addLogs(s));
        }
        return _results;
      }).call(this);
      if (suite.specs) {
        suite.specs = (function() {
          var _i, _len, _ref, _results;
          _ref = suite.specs;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            spec = _ref[_i];
            if (this.options.console === 'always' || (this.options.console === 'failure' && !spec.passed)) {
              id = Number(spec['id']);
              if (this.logs[id] && this.logs[id].length !== 0) {
                spec.logs = this.logs[id];
              }
            }
            _results.push(spec);
          }
          return _results;
        }).call(this);
      }
      return suite;
    };

    Result.prototype.addErrors = function(suite) {
      var id, s, spec;
      suite.suites = (function() {
        var _i, _len, _ref, _results;
        _ref = suite.suites;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          _results.push(this.addErrors(s));
        }
        return _results;
      }).call(this);
      if (suite.specs) {
        suite.specs = (function() {
          var _i, _len, _ref, _results;
          _ref = suite.specs;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            spec = _ref[_i];
            if (this.options.errors === 'always' || (this.options.errors === 'failure' && !spec.passed)) {
              id = Number(spec['id']);
              if (this.errors[id] && this.errors[id].length !== 0) {
                spec.errors = this.errors[id];
              }
            }
            _results.push(spec);
          }
          return _results;
        }).call(this);
      }
      return suite;
    };

    Result.prototype.cleanResult = function(suite) {
      var s, spec, _i, _len, _ref;
      suite.suites = (function() {
        var _i, _len, _ref, _results;
        _ref = suite.suites;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          _results.push(this.cleanResult(s));
        }
        return _results;
      }).call(this);
      if (suite.specs) {
        _ref = suite.specs;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          spec = _ref[_i];
          delete spec['id'];
        }
      }
      delete suite['id'];
      delete suite['parent'];
      return suite;
    };

    Result.prototype.process = function() {
      if (this.options.console !== 'never') {
        this.addLogs(this.result);
      }
      if (this.options.errors !== 'never') {
        this.addErrors(this.result);
      }
      this.cleanResult(this.result);
      return this.result;
    };

    return Result;

  })();

  if (typeof module !== 'undefined' && module.exports) {
    if (module) {
      module.exports = Result;
    }
  } else {
    if (window) {
      window.Result = Result;
    }
  }

}).call(this);
