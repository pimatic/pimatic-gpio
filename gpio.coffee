module.exports = (env) ->

  # * pimatic imports.
  convict = env.require "convict"
  Q = env.require 'q'
  assert = env.require 'cassert'

  Gpio = (if env.Gpio? then env.Gpio else require('onoff').Gpio)

  class GpioPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) ->

    createDevice: (config) =>
      return switch config.class
        when "GpioSwitch" 
          @framework.registerDevice(new GpioSwitch config)
          true
        when 'GpioPresence'
          @framework.registerDevice(new GpioPresence config)
          true
        else false


  plugin = new GpioPlugin

  deviceConfigShema = require("./device-config-shema")

  class GpioSwitch extends env.devices.PowerSwitch
    config: null

    constructor: (@config) ->
      conf = convict deviceConfigShema.GpioSwitch
      conf.load config
      conf.validate()
      assert config.gpio?

      @name = config.name
      @id = config.id

      @gpio = new Gpio config.gpio, 'out'
      super()

    getState: () ->
      return Q.fcall => @_state
        
    changeStateTo: (state) ->
      assert state is on or state is off
      return Q.ninvoke(@gpio, "write", if state then 1 else 0).then( () =>
        @_setState(state)
      )

  # ##GpioPresence Sensor
  class GpioPresence extends env.devices.PresenceSensor

    constructor: (@config) ->
      # TODO:
      conf = convict deviceConfigShema.GpioPresence
      conf.load config
      conf.validate()
      assert config.gpio?

      @id = config.id
      @name = config.name
      @inverted = conf.get 'inverted'
      @gpio = new Gpio config.gpio, 'in', 'both'

      @_readPresenceValue().done()

      @gpio.watch (err, value) =>
        if err?
          env.logger.error err.message
          env.logger.debug err.stack
        else
          @_setPresenceValue value
      super()

    _setPresenceValue: (value) ->
      assert value is 1 or value is 0
      state = (if value is 1 then yes else no)
      if @inverted then state = not state
      @_setPresence state

    _readPresenceValue: ->
      Q.ninvoke(@gpio, 'read').then( (value) =>
        @_setPresenceValue value
        return @_presence 
      )

    getPresence: () -> if @_presence? then Q(@_presence) else @_readPresentValue()


  # For testing...
  plugin.GpioSwitch = GpioSwitch
  plugin.GpioPresence = GpioPresence

  return plugin