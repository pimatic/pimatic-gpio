module.exports = (env) ->

  # * pimatic imports.
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  _ = env.require 'lodash'

  Gpio = env.Gpio or require('onoff').Gpio
  Promise.promisifyAll(Gpio.prototype)

  class GpioPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) ->

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("GpioPresence", {
        configDef: deviceConfigDef.GpioPresence, 
        createCallback: (config) => new GpioPresence(config)
      })

      @framework.deviceManager.registerDeviceClass("GpioContact", {
        configDef: deviceConfigDef.GpioContact, 
        createCallback: (config) => new GpioContact(config)
      })

      @framework.deviceManager.registerDeviceClass("GpioSwitch", {
        configDef: deviceConfigDef.GpioSwitch, 
        createCallback: (config) => new GpioSwitch(config)
      })


  plugin = new GpioPlugin

  class GpioSwitch extends env.devices.PowerSwitch

    constructor: (@config, lastState) ->
      @name = config.name
      @id = config.id

      if @config.defaultState?
        @_state = @config.defaultState
      else
        @_state = lastState?.state?.value or false

      stateToSet = (if @config.inverted then not @_state else @_state)
      @gpio = new Gpio config.gpio, (if stateToSet then "high" else "low")
      super()

    getState: () ->
      if @_state? then Promise.resolve @_state
      @gpio.readAsync().then( (value) =>
        _state = (if value is 1 then yes else no)
        if @config.inverted then @_state = not _state
        else @_state = _state
        return @_state
      )

        
    changeStateTo: (state) ->
      assert state is on or state is off
      if @config.inverted then _state = not state
      else _state = state
      @gpio.writeAsync(if _state then 1 else 0).then( () =>
        @_setState(state)
      )

  # ##GpioPresence Sensor
  class GpioContact extends env.devices.ContactSensor

    constructor: (@config, lastState) ->
      @id = config.id
      @name = config.name
      @gpio = new Gpio(config.gpio, 'in', 'both')
      @_contact = lastState?.contact?.value or false

      @_readContactValue().catch( (error) =>
        env.logger.error err.message
        env.logger.debug err.stack
      )

      @gpio.watch (err, value) =>
        if err?
          env.logger.error err.message
          env.logger.debug err.stack
        else
          @_setContactValue value
      super()

    _setContactValue: (value) ->
      assert value is 1 or value is 0
      state = (if value is 1 then yes else no)
      if @config.inverted then state = not state
      @_setContact state

    _readContactValue: ->
      @gpio.readAsync().then( (value) =>
        @_setContactValue value
        return @_contact 
      )

    getContact: () -> if @_contact? then Promise.resolve(@_contact) else @_readContactValue()

  # ##GpioPresence Sensor
  class GpioPresence extends env.devices.PresenceSensor

    constructor: (@config, lastState) ->
      @id = config.id
      @name = config.name
      @gpio = new Gpio(config.gpio, 'in', 'both')
      @_presence = lastState?.presence?.value or false

      @_readPresenceValue().catch( (error) =>
        env.logger.error err.message
        env.logger.debug err.stack
      )

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
      @gpio.readAsync().then( (value) =>
        @_setPresenceValue value
        return @_presence 
      )

    getPresence: () -> if @_presence? then Promise.resolve(@_presence) else @_readPresenceValue()


  # For testing...
  plugin.GpioSwitch = GpioSwitch
  plugin.GpioPresence = GpioPresence

  return plugin