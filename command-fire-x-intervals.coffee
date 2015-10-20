_         = require 'lodash'
commander = require 'commander'
async     = require 'async'
colors    = require 'colors'
redis     = require 'redis'
IntervalService = require './src/interval-service'

class CommandFireXIntervals
  parseOptions: =>
    commander
      .option '-n, --number-of-intervals [n]', 'Number of parallel intervals per second (defaults to 1)', @parseInt, 1
      .option '-r, --redis-uri [uri]', 'Redis client URI'
      .parse process.argv

    {@numberOfIntervals,@redisUri} = commander

  run: =>
    @parseOptions()
    client = redis.createClient @redisUri
    intervalService = new IntervalService {}, client: client
    intervalService.fetchXIntervals @numberOfIntervals, (error, intervals) =>
      async.each intervals, intervalService.fireInterval, =>
        process.exit 0

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandFireXIntervals().run()
