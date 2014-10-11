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
      @frameworkDummy = {
        deviceManager:
          registerDeviceClass: sinon.spy()
      }

    describe 'GpioPlugin', =>
      describe '#init()', =>
        it "should init", =>
          @plugin.init(null, @frameworkDummy, @config)
          assert @frameworkDummy.deviceManager.registerDeviceClass.callCount is 3
          firstCall = @frameworkDummy.deviceManager.registerDeviceClass.getCall(0)
          assert firstCall.args[0] is "GpioPresence"
          secondCall = @frameworkDummy.deviceManager.registerDeviceClass.getCall(1)
          assert secondCall.args[0] is "GpioContact"

      describe "#createCallback()", =>

        it "should create a GpioPresence", =>
          firstCall = @frameworkDummy.deviceManager.registerDeviceClass.getCall(1)
          presenceConfig = {
            id: "testPresence"
            name: "Test PresenceSensor"
            class: "GpioPresence"
            gpio: 2
          }
          @gpioPresence = firstCall.args[1].createCallback(presenceConfig)
          assert @gpioPresence.gpio?
          assert 2, @gpioPresence.gpio.pin
          assert 'in', @gpioPresence.gpio.direction
          assert @gpioPresence.gpio.watchCallback


        it "should create a GpioSwitch", =>
          secondCall = @frameworkDummy.deviceManager.registerDeviceClass.getCall(1)
          switchConfig = {
            id: "testSwitch"
            name: "Test Switch"
            class: "GpioSwitch"
            gpio: 1
          }
          @gpioSwitch = secondCall.args[1].createCallback(switchConfig)
          assert @gpioSwitch.gpio?
          assert 1, @gpioSwitch.gpio.pin
          assert 'out', @gpioSwitch.gpio.direction
