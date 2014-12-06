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
        @reporter.specDone( { status: 'passed', failedExpectations: [] } )
        @reporter.specDone( { status: 'failed', failedExpectations: [{
            matcherName:"toEqual",
            message: "Expected 2 to equal 5"
        }] })
        @reporter.specDone( { status: 'passed', failedExpectations: [] } )
        @reporter.specDone( { status: 'pending', failedExpectations: [] } )
        results = @reporter.results()
        expect( results ).to.have.property('stats')
        expect( results.stats )
            .to.have.property('specs').and.equal(4)
        expect( results.stats )
            .to.have.property('failed').and.equal(1)
        expect( results.stats )
            .to.have.property('pending').and.equal(1)
