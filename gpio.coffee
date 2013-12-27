# 
convict = require "convict"
Q = require 'q'
assert = require 'cassert'
Gpio = require('onoff').Gpio

module.exports = (env) ->

  class GpioPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) ->

    createActuator: (config) =>
      return switch config.class
        when "GpioSwitch" 
          @framework.registerActuator(new GpioSwitch config)
          true
        else false

    createSensor: (config) =>
      return switch config.class
        when 'GpioPresents'
          @framework.registerSensor(new GpioPresents config)

  plugin = new GpioPlugin

  actuatorConfigShema = require("./actuator-config-shema")

  class GpioSwitch extends env.actuators.PowerSwitch
    config: null

    constructor: (@config) ->
      conf = convict actuatorConfigShema.GpioSwitch
      conf.load config
      conf.validate()
      assert config.gpio?

      @name = config.name
      @id = config.id

      @gpio = new Gpio config.gpio, 'out'

    getState: () ->
      return Q.fcall -> @_state
        
    changeStateTo: (state) ->
      assert state is on or state is off
      return Q.ninvoke(@gpio, "write", if state then 1 else 0).then( () ->
        @_setState(state)
      )

  # ##GpioPresents Sensor
  class GpioPresents extends env.sensors.PresentsSensor

    constructor: (@config) ->
      # TODO:
      # conf = convict sensorConfigShema.GpioPresents
      # conf.load config
      # conf.validate()
      assert config.gpio?

      @id = config.id
      @name = config.name

      @gpio = new Gpio config.gpio, 'in', 'both'
      @gpio.watch (err, value) =>
        if err?
          env.logger.error err.message
          env.logger.debug err.stack
        else
          @_setPesent (if value is 1 then yes else no)

  # For testing...
  plugin.GpioSwitch = GpioSwitch
  plugin.GpioPresents = GpioPresents

  return plugin