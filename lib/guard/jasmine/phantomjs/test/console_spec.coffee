sinon    = require 'sinon'
{expect} = require 'chai'

Console  = require '../src/console'

describe 'console', ->
  beforeEach ->
    @log = sinon.stub()
    @console = { log: @log }

    new Console(@console)

  describe '#log', ->
    describe 'with strings', ->
      it 'logs a single string', ->
        @console.log 'Hello logger'
        expect(@log.args[0][0]).to.equal 'Hello logger'

      it 'concatenates multipe strings', ->
        @console.log 'Hello logger', 'We welcome you', 'Here on Earth'
        expect(@log.args[0][0]).to.equal 'Hello logger We welcome you Here on Earth'

      it 'replaces a single %s', ->
        @console.log 'Hello %s!', 'logger'
        expect(@log.args[0][0]).to.equal 'Hello logger!'

      it 'replaces multiple %s', ->
        @console.log 'Hello %s, we welcome you to %s!', 'logger', 'Switzerland'
        expect(@log.args[0][0]).to.equal 'Hello logger, we welcome you to Switzerland!'

      it 'attaches %s surplus strings', ->
        @console.log 'Hello %s, we welcome you to Switzerland!', 'logger', 'Yay!'
        expect(@log.args[0][0]).to.equal 'Hello logger, we welcome you to Switzerland! Yay!'

    describe 'with numbers', ->
      it 'logs a single number', ->
        @console.log 1
        expect(@log.args[0][0]).to.equal '1'

      it 'concatenates multipe numbers', ->
        @console.log 1, 2, 3, 4
        expect(@log.args[0][0]).to.equal '1 2 3 4'

      it 'replaces a single %d', ->
        @console.log 'Hello %d!', 1
        expect(@log.args[0][0]).to.equal 'Hello 1!'

      it 'replaces a single %i', ->
        @console.log 'Hello %i!', 3
        expect(@log.args[0][0]).to.equal 'Hello 3!'

      it 'replaces multiple %d', ->
        @console.log 'I can count %d, %d and %d!', 1, 2, 3
        expect(@log.args[0][0]).to.equal 'I can count 1, 2 and 3!'

      it 'replaces multiple %i', ->
        @console.log 'I can count reverse %i, %i and %i!', 3, 2, 1
        expect(@log.args[0][0]).to.equal 'I can count reverse 3, 2 and 1!'

      it 'attaches %d surplus numbers', ->
        @console.log 'Hello %d!', 1, 2, 3
        expect(@log.args[0][0]).to.equal 'Hello 1! 2 3'

      it 'attaches %i surplus numbers', ->
        @console.log 'Hello %i!', 1, 2, 3
        expect(@log.args[0][0]).to.equal 'Hello 1! 2 3'

    describe 'with objects', ->
      it 'logs a boolean', ->
        @console.log true, false
        expect(@log.args[0][0]).to.equal 'true false'

      it 'logs a date', ->
        @console.log new Date('Thu Mar 08 2012 20:28:56 GMT+0100 (CET)')
        expect(@log.args[0][0]).to.equal 'Thu, 08 Mar 2012 19:28:56 GMT'

      it 'logs an array', ->
        @console.log [1, 2, 3, 4]
        expect(@log.args[0][0]).to.equal '[ 1, 2, 3, 4 ]'

      it 'logs an object', ->
        @console.log { a: 1 }
        expect(@log.args[0][0]).to.equal '{ a: 1 }'

      it 'logs a nested object', ->
        @console.log "Hello object %o. Nice to meet you", { a: 1, b: { x: 1 } }
        expect(@log.args[0][0]).to.equal 'Hello object { a: 1, b: { x: 1 } }. Nice to meet you'

      it 'logs a nested object until depth 3', ->
        @console.log "Hello object %o. Nice to meet you", { a: 1, b: { x: { a: 1, b: { x: 1 } } } }
        expect(@log.args[0][0]).to.equal 'Hello object { a: 1, b: { x: { a: 1, b: [Object] } } }. Nice to meet you'

    describe 'with an Object that implements toString()', ->
      it '%s logs the custom string representation', ->
        @console.log 'I have a toString(): %s!', { toString: -> '[Yepa]' }
        expect(@log.args[0][0]).to.equal 'I have a toString(): [Yepa]!'

      it '%o logs the object representation', ->
        @console.log 'I have a toString(): %o!', { toString: -> '[Yepa]' }
        expect(@log.args[0][0]).to.equal 'I have a toString(): { toString: [Function] }!'

    describe 'with an Object that implements toJSON()', ->
      it '%o logs the custom JSON representation', ->
        @console.log 'I have a toJSON(): %o!', { toJSON: -> { a: 1 } }
        expect(@log.args[0][0]).to.equal 'I have a toJSON(): { a: 1 }!'

  describe '#info', ->
    it 'prefixes a string with INFO', ->
      @console.info true, { a: 1 }, 'Hello logger'
      expect(@log.args[0][0]).to.equal 'INFO: true { a: 1 } Hello logger'

  describe '#warn', ->
    it 'prefixes a string with WARN', ->
      @console.warn true, { a: 1 }, 'Hello logger'
      expect(@log.args[0][0]).to.equal 'WARN: true { a: 1 } Hello logger'

  describe '#error', ->
    it 'prefixes a string with ERROR', ->
      @console.error true, { a: 1 }, 'Hello logger'
      expect(@log.args[0][0]).to.equal 'ERROR: true { a: 1 } Hello logger'

  describe '#debug', ->
    it 'prefixes a string with DEBUG', ->
      @console.debug true, { a: 1 }, 'Hello logger'
      expect(@log.args[0][0]).to.equal 'DEBUG: true { a: 1 } Hello logger'
