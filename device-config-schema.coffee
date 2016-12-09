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
      defaultState:
        description: "State to set on startup, if not given, last state will be restored"
        type: "boolean"
        required: false
      debounceTimeout:
        description: "Optional timeout in ms to software debounce the switch"
        type: "number"
        required: false
  }
  GpioContact: {
    title: "GpioContact config options"
    type: "object"
    extensions: ["xLink", "xOpenedLabel", "xClosedLabel"]
    properties:
      gpio:
        description: "The gpio pin"
        type: "number"
      inverted:
        description: "LOW = closed?"
        type: "boolean"
        default: false
      debounceTimeout:
        description: "Optional timeout in ms to software debounce the switch"
        type: "number"
        required: false
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
      debounceTimeout:
        description: "Optional timeout in ms to software debounce the switch"
        type: "number"
        required: false
  }
}
