# Capture statements that were logged to the console
# during spec execution.
#
# To do so it substitues it's own functions for the console.<levels>
#
class ConsoleCapture
    @levels: ['log','info','warn','error','debug' ]
    @original = console

    @original_levels = {}
    @original_levels[level] = console[level] for level in ConsoleCapture.levels

    constructor:->
        @original = {}
        @captured = []
        this._reassign_level( level ) for level in ConsoleCapture.levels

    revert: ->
        for level in ConsoleCapture.levels
            ConsoleCapture.original[level] = ConsoleCapture.original_levels[level]

    _reassign_level: ( level )->
        my = this
        console[level] = ->
            args = Array.prototype.slice.call(arguments, 0)
            my.captured.push( [ level ].concat( args ) )
            ConsoleCapture.original_levels[ level ].apply( ConsoleCapture.original, arguments )


# Implements a Jasmine reporter
class window.GuardReporter
    @STACK_MATCHER=new RegExp("__spec__\/(.*):([0-9]+)","g")

    jasmineStarted: ->
        @console = new ConsoleCapture();
        @startedAt = Date.now()
        @currentSuite = { suites: [] }
        @stack     = [ @currentSuite ]

    suiteStarted: (suite)->
        suite = jQuery.extend({ specs: [], suites: [] }, suite )
        @currentSuite.suites.push( suite )
        @currentSuite = suite
        @stack.push(suite)

    suiteDone: (suite)->
        @stack.pop()
        @currentSuite = @stack[@stack.length-1]

    jasmineDone: ->
        @resultComplete = true

    specDone: (spec)->
        @resultReceived = true
        spec = jQuery.extend({ logs: @console.captured, errors: [], passed: 'passed' == spec.status }, spec )
        for failure in spec.failedExpectations
            error = jQuery.extend({trace:[]}, failure )
            while match = GuardReporter.STACK_MATCHER.exec( failure.stack )
                error.trace.push({ file: match[1], line: parseInt(match[2]) })
            delete error.stack
            spec.errors.push( error )
        delete spec.failedExpectations
        @currentSuite.specs.push( spec )

        this.resetConsoleLog()
        true

    resetConsoleLog: ->
        @console.revert()
        @console = new ConsoleCapture

    eachSuite: (suite)->
        suites = [].concat( suite.suites )
        for suite in suite.suites
            suites = suites.concat( this.eachSuite(suite) )
        suites

    results: ->
        spec_count    = 0
        failure_count = 0
        for suite in this.eachSuite(@stack[0])
            spec_count += suite.specs.length
            for spec in suite.specs
                failure_count += 1 unless spec.passed
        {
            stats: {
                specs: spec_count,
                failures: failure_count,
                time: Date.now() - @statedAt
            },
            suites: @stack[0].suites
        }
