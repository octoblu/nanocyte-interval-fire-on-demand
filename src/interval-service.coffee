_ = require 'lodash'
redis = require 'redis'
debug = require('debug')('nanocyte-interval-fire-on-demand:interval-service')
MeshbluHttp = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'

class IntervalService
  constructor: ({@prefix}, {@meshbluHttp, @client})->
    @prefix ?= 'interval/time'
    meshbluConfig = new MeshbluConfig().toJSON()
    @meshbluHttp ?= new MeshbluHttp meshbluConfig
    @client ?= redis.createClient()

  fetchXIntervals: (numberOfIntervals, offset, callback) ->
    @client.keys "#{@prefix}/*", (error, result) =>
      return callback error if error?
      sortedKeys = _.sortBy result
      intervalKeys = _.slice sortedKeys, offset, numberOfIntervals+offset
      callback null, intervalKeys

  fetchFlowIntervals: (flowId, callback) ->
    @client.keys "#{@prefix}/#{flowId}/*", (error, result) =>
      return callback error if error?
      callback null, result

  fireInterval: (interval, callback) =>
    interval = interval.replace("#{@prefix}/", '')
    [device, nonce] = interval.split '/'
    debug 'firing interval', device, nonce
    message =
      devices: [device]
      payload:
        from: nonce
    @meshbluHttp.message message, callback

module.exports = IntervalService
