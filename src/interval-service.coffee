_ = require 'lodash'
redis = require 'redis'
debug = require('debug')('nanocyte-interval-fire-on-demand:interval-service')
MeshbluHttp = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'

class IntervalService
  constructor: (options, {@meshbluHttp, @client})->
    meshbluConfig = new MeshbluConfig().toJSON()
    @meshbluHttp ?= new MeshbluHttp meshbluConfig
    @client ?= redis.createClient()

  fetchXIntervals: (x, callback) ->
    @client.keys 'interval/time/*', (error, result) =>
      return callback error if error?
      sortedKeys = _.sortBy result
      intervalKeys = _.slice sortedKeys, 0, x
      callback null, intervalKeys

  fireInterval: (interval, callback) =>
    [interval, time, device, nonce] = interval.split '/'
    debug 'firing interval', device, nonce
    message =
      devices: [device]
      payload:
        from: nonce
    @meshbluHttp.message message, callback

module.exports = IntervalService
