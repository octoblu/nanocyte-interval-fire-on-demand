_         = require 'lodash'
commander = require 'commander'
async     = require 'async'
colors    = require 'colors'
redis     = require 'redis'
IntervalService = require './src/interval-service'

class CommandFireXIntervals
  parseOptions: =>
    commander
      .option '-n, --number-of-intervals <n>', 'Number of parallel intervals per second (defaults to 1)', parseInt
      .option '-o, --offset <o>', 'Offset start position (defaults to 0)', parseInt
      .option '-r, --redis-uri <uri>', 'Redis client URI'
      .parse process.argv

    {@numberOfIntervals,@offset,@redisUri} = commander
    @offset ?= 0
    @numberOfIntervals ?= 1

  run: =>
    @parseOptions()
    client = redis.createClient @redisUri
    intervalService = new IntervalService {}, client: client
    intervalService.fetchXIntervals @numberOfIntervals, @offset, (error, intervals) =>
      async.each intervals, intervalService.fireInterval, =>
        process.exit 0

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandFireXIntervals().run()
