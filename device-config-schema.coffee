module.exports =
  GpioSwitch:
    gpio:
      description: "The gpio pin"
      type: "number"
  GpioPresence:
    gpio:
      description: "The gpio pin"
      type: "number"
    inverted:
      description: "LOW = present?"
      type: "boolean"
      default: false