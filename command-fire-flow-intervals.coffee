_         = require 'lodash'
commander = require 'commander'
async     = require 'async'
colors    = require 'colors'
redis     = require 'redis'
IntervalService = require './src/interval-service'

class CommandFireFlowIntervals
  parseOptions: =>
    commander
      .option '-f, --flow-id [uuid]', 'Flow Id'
      .option '-r, --redis-uri [uri]', 'Redis client URI'
      .parse process.argv

    {@flowId,@redisUri} = commander

    @die 'No flow id' unless @flowId?

  run: =>
    @parseOptions()
    client = redis.createClient @redisUri
    intervalService = new IntervalService {}, client: client
    intervalService.fetchFlowIntervals @flowId, (error, intervals) =>
      async.eachSeries intervals, intervalService.fireInterval, =>
        process.exit 0

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandFireFlowIntervals().run()
