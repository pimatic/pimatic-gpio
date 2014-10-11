module.exports ={
  title: "pimatic-gpio device config schemas"
  GpioSwitch: {
    title: "GpioSwitch config options"
    type: "object"
    extensions: ["xConfirm", "xLink", "xOnLabel", "xOffLabel"]
    properties:
      gpio:
        description: "The gpio pin"
        type: "number"
      inverted:
        description: "active low?"
        type: "boolean"
        default: false
  }
  GpioContact: {
    title: "GpioContact config options"
    type: "object"
    extensions: ["xLink"]
    properties:
      gpio:
        description: "The gpio pin"
        type: "number"
      inverted:
        description: "LOW = closed?"
        type: "boolean"
        default: false
  }
  GpioPresence: {
    title: "GpioPresence config options"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel"]
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