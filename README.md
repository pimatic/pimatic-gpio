pimatic-gpio
============
Actuators and sensors for the Raspberry Pi GPIO pins. This plugin uses the node.js module
[onoff](https://github.com/fivdi/onoff).

Plugin Configuration
-------------
You can load the plugin by editing your `config.json` to include:

    { 
       "plugin": "gpio"
    }

in the `plugins` Array. 

Device Configuration
-------------
Devices can be added by adding them to the `devices` Array in the config file.
Set the `class` property to `GpioSwitch`, `GpioPresence`, or `GpioContact`, respectively. By default, 
the device state will be `true` , i.e. *on*, *opened*, or *present*, when the GPIO pin is HIGH. If you need 
the device to be active on LOW, set the property `inverted` to `true`. 

The `GpioSwitch` device additionally provides the optional `defaultState` property which can be used to set the 
initial switch state to the given value. If the property is not present the last state will be recovered from 
database or it will be set to `false` if the last state cannot be obtained. 

For device configuration options see the [device-config-schema](actuator-config-schema.html) file.

### GPIO Pin Numbering

Use the GPIO numbers from the [RPi Low-level peripherals wiki page](http://elinux.org/RPi_Low-level_peripherals#General_Purpose_Input.2FOutput_.28GPIO.29). 

### Device examples

#### GpioSwitch Device ("active LOW" and "defaultState")

    { 
      "id": "led-light",
      "class": "GpioSwitch", 
      "name": "led light",
      "gpio": 17,
      "inverted": true,
      "defaultState": false
    }

#### GpioPresence Sensor

    { 
      "id": "presence-sensor",
      "class": "GpioPresence", 
      "name": "motion detector",
      "gpio": 18 
    }

#### GpioContact Sensor

    { 
      "id": "contact-sensor",
      "class": "GpioContact", 
      "name": "contact detector",
      "debounceTimeout": 50,
      "gpio": 18 
    }
