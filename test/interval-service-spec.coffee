_ = require 'lodash'
IntervalService = require '../src/interval-service'
redis = require 'redis'
async = require 'async'

describe 'IntervalService', ->
  beforeEach ->
    @client = redis.createClient()
    @meshbluHttp = message: sinon.stub()
    @dependencies = meshbluHttp: @meshbluHttp, client: @client
    @sut = new IntervalService prefix: 'test/interval/time', @dependencies

  beforeEach (done) ->
    async.parallel [
      (next) => @client.set 'test/interval/time/a-uuid/a-nonce', '1000', next
      (next) => @client.set 'test/interval/time/another-uuid/another-nonce', '1000', next
      (next) => @client.set 'test/interval/time/yet-another-uuid/yet-another-nonce', '1000', next
    ], done

  afterEach (done) ->
    async.parallel [
      (next) => @client.del 'test/interval/time/a-uuid/a-nonce', next
      (next) => @client.del 'test/interval/time/another-uuid/another-nonce', next
      (next) => @client.del 'test/interval/time/yet-another-uuid/yet-another-nonce', next
    ], done

  describe '->fetchXIntervals', ->
    describe 'when given 1 interval', ->
      beforeEach (done) ->
        @sut.fetchXIntervals 1, (@error, @result) =>
          done()

      it 'should return 1 interval', ->
        expect(@result).to.deep.equal [
          'test/interval/time/a-uuid/a-nonce'
        ]

    describe 'when given 2 intervals', ->
      beforeEach (done) ->
        @sut.fetchXIntervals 2, (@error, @result) =>
          done()

      it 'should return 2 intervals', ->
        expect(@result).to.deep.equal [
          'test/interval/time/a-uuid/a-nonce'
          'test/interval/time/another-uuid/another-nonce'
        ]

  describe '->fetchFlowIntervals', ->
    describe 'when given a-uuid', ->
      beforeEach (done) ->
        @sut.fetchFlowIntervals 'a-uuid', (@error, @result) =>
          done()

      it 'should return 1 interval', ->
        expect(@result).to.deep.equal [
          'test/interval/time/a-uuid/a-nonce'
        ]

    # describe 'when given 2 intervals', ->
    #   beforeEach (done) ->
    #     @sut.fetchXIntervals 2, (@error, @result) =>
    #       done()
    #
    #   it 'should return 2 intervals', ->
    #     expect(@result).to.deep.equal [
    #       'test/interval/time/a-uuid/a-nonce'
    #       'test/interval/time/another-uuid/another-nonce'
    #     ]

  describe '->fireInterval', ->
    beforeEach (done) ->
      @meshbluHttp.message.yields null
      @sut.fireInterval 'test/interval/time/a-uuid/a-nonce', =>
        done()

    it 'should send a meshblu message', ->
      expect(@meshbluHttp.message).to.have.been.calledWith
        devices: ['a-uuid']
        payload:
          from: 'a-nonce'
