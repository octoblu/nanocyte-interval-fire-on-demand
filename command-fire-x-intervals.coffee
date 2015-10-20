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
      .option '-h, --hostname [host]', 'Redis Hostname'
      .option '-p, --port [port]', 'Redis port'
      .parse process.argv

    {@numberOfIntervals,@hostname,@port} = commander

  run: =>
    @parseOptions()
    client = redis.createClient @port, @hostname
    intervalService = new IntervalService {}, client: client
    intervalService.fetchXIntervals @numberOfIntervals, (error, intervals) =>
      async.eachSeries intervals, intervalService.fireInterval, =>
        process.exit 0

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandFireXIntervals().run()
