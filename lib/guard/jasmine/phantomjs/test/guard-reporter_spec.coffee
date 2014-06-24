sinon    = require 'sinon'
{expect} = require 'chai'

GuardReporter = require '../src/guard-reporter'

describe 'Reporter', ->
    beforeEach ->
        @reporter = new GuardReporter
        @reporter.jasmineStarted()

    it 'captures the console', ->
        @reporter.suiteStarted({name:'Blank'})
        console.log("A %s Logging", "Test")
        console.warn("This is your last warning")
        @reporter.specDone( { failedExpectations: [] } )
        expect( @reporter.results() )
            .to.have.deep.property('.suites[0].specs[0].logs')
            .and.equal([
                [ 'log', 'A %s Logging', "Test" ],
                [ 'warn', 'This is your last warning' ]
                ])

    it "reports counts", ->
        @reporter.suiteStarted({name:'Blank'})

        console.log("A %s Logging", "Test")
        console.warn("This is your last warning")
        @reporter.specDone( { failedExpectations: [{},stack:''] } )
        @reporter.specDone( { failedExpectations: [], status: 'passed' } )
        results = @reporter.results()
        expect( results ).to.have.property('stats')
        expect( results.stats )
            .to.have.property('specs').and.equal(2)
        expect( results.stats )
            .to.have.property('failures').and.equal(1)
