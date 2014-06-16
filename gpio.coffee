module.exports = (env) ->

  # * pimatic imports.
  convict = env.require "convict"
  Q = env.require 'q'
  assert = env.require 'cassert'
  _ = env.require 'lodash'

  Gpio = env.Gpio or require('onoff').Gpio

  class GpioPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) ->

      deviceConfigDef = require("./device-config-schema")

      @framework.registerDeviceClass("GpioPresence", {
        configDef: deviceConfigDef.GpioPresence, 
        createCallback: (config) => new GpioPresence(config)
      })

      @framework.registerDeviceClass("GpioSwitch", {
        configDef: deviceConfigDef.GpioSwitch, 
        createCallback: (config) => new GpioSwitch(config)
      })


  plugin = new GpioPlugin

  class GpioSwitch extends env.devices.PowerSwitch

    constructor: (@config) ->
      @name = config.name
      @id = config.id
      @gpio = new Gpio config.gpio, 'out', 'both'

      # Watch for state changes from outside
      @gpio.watch (err, value) =>
        if err?
          env.logger.error err.message
          env.logger.debug err.stack
        else
          _state = (if value is 1 then yes else no)
          if @config.inverted then state = not _state
          else state = _state
          @_setState(state)

      super()

    getState: () ->
      if @_state? then Q @_state
      else Q.ninvoke(@gpio, 'read').then( (value) =>
        _state = (if value is 1 then yes else no)
        if @config.inverted then @_state = not _state
        else @_state = _state
        return @_state
      )

        
    changeStateTo: (state) ->
      assert state is on or state is off
      if @config.inverted then _state = not state
      else _state = state
      return Q.ninvoke(@gpio, "write", if _state then 1 else 0).then( () =>
        @_setState(state)
      )

  # ##GpioPresence Sensor
  class GpioPresence extends env.devices.PresenceSensor

    constructor: (@config) ->
      @id = config.id
      @name = config.name
      @gpio = new Gpio(config.gpio, 'in', 'both')

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
      if @config.inverted then state = not state
      @_setPresence state

    _readPresenceValue: ->
      Q.ninvoke(@gpio, 'read').then( (value) =>
        @_setPresenceValue value
        return @_presence 
      )

    getPresence: () -> if @_presence? then Q(@_presence) else @_readPresenceValue()


  # For testing...
  plugin.GpioSwitch = GpioSwitch
  plugin.GpioPresence = GpioPresence

  return plugin