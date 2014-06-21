module.exports ={
  title: "pimatic-gpio device config schemas"
  GpioSwitch: {
    title: "GpioSwitch config options"
    type: "object"
    properties:
      gpio:
        description: "The gpio pin"
        type: "number"
      inverted:
        description: "active low?"
        type: "boolean"
        default: false
  }
  GpioPresence: {
    title: "GpioPresence config options"
    type: "object"
    properties:
      gpio:
        description: "The gpio pin"
        type: "number"
      inverted:
        description: "LOW = present?"
        type: "boolean"
        default: false
  }
}