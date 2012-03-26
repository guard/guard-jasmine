sinon    = require 'sinon'
{expect} = require 'chai'

Result  = require '../src/result'

describe 'Result', ->
  beforeEach ->
    @logObj =
      0: ['Log 1', 'Another Log']
      1: ['Log 2']
      3: ['Log 4', 'more Logs']

    @errorsObj =
      1: [{ msg: 'Failure 1', trace: { file: 'a file' }}]
      2: [{ msg: 'Failure 2', trace: { file: 'another file' }}]
      3: [{ msg: 'Failure 3', trace: { file: 'file' }}]

    @resultObj =
      passed: false
      stats:
        failures: 1
        specs: 4
        time: 0.10
      specs: [
        {
          description: "Spec 1"
          id: 0
          passed: true
        }
      ]
      suites: [
        {
          description: "Suite 1"
          id: 0
          passed: true
          specs: [
            {
              description: "Spec 2"
              id: 1
              passed: true
            }
            {
              description: "Spec 3"
              id: 2
              passed: true
            }
          ]
          suites: [
            description: "Suite 2"
            id: 1
            passed: false
            specs: [
              {
                description: "Spec 4"
                id: 3
                passed: false
              }
            ]
            suites: []
          ]
        }
      ]

  describe '#prepare', ->
    describe 'when console and errors are :never', ->
      beforeEach ->
        @result = new Result(@resultObj, @logObj, @errorsObj, { console: 'never', errors: 'never' }).process()

      it 'does not add the log and error statements to the specs', ->
        expected = {
          passed: false
          stats:
            failures: 1
            specs: 4
            time: 0.10
          specs: [
            {
              description: "Spec 1"
              passed: true
            }
          ]
          suites: [
            {
              description: "Suite 1"
              passed: true
              specs: [
                {
                  description: "Spec 2"
                  passed: true
                }
                {
                  description: "Spec 3"
                  passed: true
                }
              ]
              suites: [
                description: "Suite 2"
                passed: false
                specs: [
                  {
                    description: "Spec 4"
                    passed: false
                  }
                ]
                suites: []
              ]
            }
          ]
        }

        expect(@result).to.eql expected

    describe 'when console is :always', ->
      beforeEach ->
        @result = new Result(@resultObj, @logObj, @errorsObj, { console: 'always', errors: 'never' }).process()

      it 'does add all the log statements to the specs', ->
        expected = {
          passed: false
          stats:
            failures: 1
            specs: 4
            time: 0.10
          specs: [
            {
              description: "Spec 1"
              passed: true
              logs: ['Log 1', 'Another Log']
            }
          ]
          suites: [
            {
              description: "Suite 1"
              passed: true
              specs: [
                {
                  description: "Spec 2"
                  passed: true
                  logs: ['Log 2']
                }
                {
                  description: "Spec 3"
                  passed: true
                }
              ]
              suites: [
                description: "Suite 2"
                passed: false
                specs: [
                  {
                    description: "Spec 4"
                    passed: false
                    logs: ['Log 4', 'more Logs']
                  }
                ]
                suites: []
              ]
            }
          ]
        }

        expect(@result).to.eql expected

    describe 'when console is :failure', ->
      beforeEach ->
        @result = new Result(@resultObj, @logObj, @errorsObj, { console: 'failure', errors: 'never' }).process()

      it 'does add the log statements to the failing specs', ->
        expected = {
          passed: false
          stats:
            failures: 1
            specs: 4
            time: 0.10
          specs: [
            {
              description: "Spec 1"
              passed: true
            }
          ]
          suites: [
            {
              description: "Suite 1"
              passed: true
              specs: [
                {
                  description: "Spec 2"
                  passed: true
                }
                {
                  description: "Spec 3"
                  passed: true
                }
              ]
              suites: [
                description: "Suite 2"
                passed: false
                specs: [
                  {
                    description: "Spec 4"
                    passed: false
                    logs: ['Log 4', 'more Logs']
                  }
                ]
                suites: []
              ]
            }
          ]
        }

        expect(@result).to.eql expected

    describe 'when errors is :always', ->
      beforeEach ->
        @result = new Result(@resultObj, @logObj, @errorsObj, { console: 'never', errors: 'always' }).process()

      it 'does add all the log statements to the specs', ->
        expected = {
          passed: false
          stats:
            failures: 1
            specs: 4
            time: 0.10
          specs: [
            {
              description: "Spec 1"
              passed: true
            }
          ]
          suites: [
            {
              description: "Suite 1"
              passed: true
              specs: [
                {
                  description: "Spec 2"
                  passed: true
                  errors: [{ msg: 'Failure 1', trace: { file: 'a file' }}]
                }
                {
                  description: "Spec 3"
                  passed: true
                  errors: [{ msg: 'Failure 2', trace: { file: 'another file' }}]
                }
              ]
              suites: [
                description: "Suite 2"
                passed: false
                specs: [
                  {
                    description: "Spec 4"
                    passed: false
                    errors: [{ msg: 'Failure 3', trace: { file: 'file' }}]
                  }
                ]
                suites: []
              ]
            }
          ]
        }

        expect(@result).to.eql expected

    describe 'when errors is :failure', ->
      beforeEach ->
        @result = new Result(@resultObj, @logObj, @errorsObj, { console: 'never', errors: 'failure' }).process()

      it 'does add the log statements to the failing specs', ->
        expected = {
          passed: false
          stats:
            failures: 1
            specs: 4
            time: 0.10
          specs: [
            {
              description: "Spec 1"
              passed: true
            }
          ]
          suites: [
            {
              description: "Suite 1"
              passed: true
              specs: [
                {
                  description: "Spec 2"
                  passed: true
                }
                {
                  description: "Spec 3"
                  passed: true
                }
              ]
              suites: [
                description: "Suite 2"
                passed: false
                specs: [
                  {
                    description: "Spec 4"
                    passed: false
                    errors: [{ msg: 'Failure 3', trace: { file: 'file' }}]
                  }
                ]
                suites: []
              ]
            }
          ]
        }

        expect(@result).to.eql expected
