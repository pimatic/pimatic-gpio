module.exports = (env) ->

  sinon = env.require 'sinon'
  assert = env.require "assert"

  describe "gpio", ->

    before =>
      env.Gpio = (
        class GpioDummy 
          constructor: (@pin, @direction) ->
          watch: (@watchCallback) ->
          read: (@readCallback) ->
      )

      @plugin = (env.require 'pimatic-gpio') env
      @config = {}
      @frameworkDummy = {}

    describe 'GpioPlugin', =>
      describe '#init()', =>
        it "should init", =>
          @plugin.init(null, @frameworkDummy, @config)

      describe "#createDevice()", =>
        it "should create a GpioSwitch", =>
          registerDevice = sinon.spy()
          @frameworkDummy.registerDevice = registerDevice

          switchConfig =
            id: "testSwitch"
            name: "Test Switch"
            class: "GpioSwitch"
            gpio: 1

          @plugin.createDevice switchConfig
          assert registerDevice.called
          @gpioSwitch = registerDevice.getCall(0).args[0]
          assert @gpioSwitch.gpio?
          assert 1, @gpioSwitch.gpio.pin
          assert 'out', @gpioSwitch.gpio.direction

        it "should create a GpioPresence", =>
          registerDevice = sinon.spy()
          @frameworkDummy.registerDevice = registerDevice

          presenceConfig =
            id: "testPresence"
            name: "Test PresenceSensor"
            class: "GpioPresence"
            gpio: 2

          @plugin.createDevice presenceConfig
          assert registerDevice.called
          @gpioPresence = registerDevice.getCall(0).args[0]
          assert @gpioPresence.gpio?
          assert 2, @gpioPresence.gpio.pin
          assert 'in', @gpioPresence.gpio.direction
          assert @gpioPresence.gpio.watchCallback

    describe "GpioSwitch", =>

