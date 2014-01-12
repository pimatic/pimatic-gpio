module.exports = (env) ->

  # * pimatic imports.
  convict = env.require "convict"
  Q = env.require 'q'
  assert = env.require 'cassert'

  Gpio = require('onoff').Gpio


  class GpioPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) ->

    createDevice: (config) =>
      return switch config.class
        when "GpioSwitch" 
          @framework.registerDevice(new GpioSwitch config)
          true
        when 'GpioPresents'
          @framework.registerDevice(new GpioPresents config)
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

    getState: () ->
      return Q.fcall => @_state
        
    changeStateTo: (state) ->
      assert state is on or state is off
      return Q.ninvoke(@gpio, "write", if state then 1 else 0).then( () =>
        @_setState(state)
      )

  # ##GpioPresents Sensor
  class GpioPresents extends env.devices.PresentsSensor

    constructor: (@config) ->
      # TODO:
      conf = convict deviceConfigShema.GpioPresents
      conf.load config
      conf.validate()
      assert config.gpio?

      @id = config.id
      @name = config.name
      @inverted = conf.get 'inverted'
      @gpio = new Gpio config.gpio, 'in', 'both'

      Q.ninvoke(@gpio, 'read').then( (value) =>
        @_setPresentValue value 
      ).catch( (err) ->
        env.logger.error err.message
        env.logger.debug err.stack
      ).done()

      @gpio.watch (err, value) =>
        if err?
          env.logger.error err.message
          env.logger.debug err.stack
        else
          @_setPresentValue value

    _setPresentValue: (value) ->
      assert value is 1 or value is 0
      state = (if value is 1 then yes else no)
      if @inverted then state = not state
      @_setPresent state

  # For testing...
  plugin.GpioSwitch = GpioSwitch
  plugin.GpioPresents = GpioPresents

  return plugin