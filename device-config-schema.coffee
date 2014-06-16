module.exports =
  GpioSwitch:
    gpio:
      description: "The gpio pin"
      type: "number"
    inverted:
      description: "active low?"
      type: "boolean"
      default: false
  GpioPresence:
    gpio:
      description: "The gpio pin"
      type: "number"
    inverted:
      description: "LOW = present?"
      type: "boolean"
      default: false
