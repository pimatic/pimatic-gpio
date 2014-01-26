pimatic gpio plugin
=======================
Actuators and sensors for the raspberry pi gpio pins. This plugin uses the node.js module
[onoff](https://github.com/fivdi/onoff).  

Configuration
-------------
You can load the plugin by editing your `config.json` to include:

    { 
       "plugin": "gpio"
    }

in the `plugins` Array. 
Devices can be added bei adding them to the `devices` Array in the config file.
Set the `class` attribute to `GpioSwitch`. 

For device configuration options see the [device-config-schema](actuator-config-schema.html) file.

GPIO Pin Numbering
-------------
Use the GPIO numbers from the [RPi Low-level peripherals wiki page](http://elinux.org/RPi_Low-level_peripherals#General_Purpose_Input.2FOutput_.28GPIO.29). 

Device examples
---------------

###GpioSwitch Device

    { 
      "id": "led-light",
      "class": "GpioSwitch", 
      "name": "led light",
      "gpio": 17 
    }

###GpioPresence Sensor

    { 
      "id": "presence-sensor",
      "class": "GpioPresence", 
      "name": "motion detector",
      "gpio": 18 
    }

