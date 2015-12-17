pimatic gpio plugin
=======================
Actuators and sensors for the raspberry pi gpio pins. This plugin uses the node.js module
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
Set the `class` property to `GpioSwitch`. By default, the device state will be `true , i.e. *on*, *opened*, 
or *present*, when the GPIO pin is HIGH. If you need the device to be active on LOW, set the 
property `inverted` to `true`.

For device configuration options see the [device-config-schema](actuator-config-schema.html) file.

### GPIO Pin Numbering

Use the GPIO numbers from the [RPi Low-level peripherals wiki page](http://elinux.org/RPi_Low-level_peripherals#General_Purpose_Input.2FOutput_.28GPIO.29). 

### Device examples


#### GpioSwitch Device

    { 
      "id": "led-light",
      "class": "GpioSwitch", 
      "name": "led light",
      "gpio": 17 
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
      "gpio": 18 
    }
