data:extend({
  {
    type = "double-setting",
    name = "train-stop-item-color-vibrance-push",
    setting_type = "runtime-global",
    default_value = 1.75,
    minimum_value = 0.5,
    maximum_value = 3.0,
    order = "a"
  },
  {
    type = "double-setting",
    name = "train-stop-item-color-saturation-boost",
    setting_type = "runtime-global",
    default_value = 1.75,
    minimum_value = 0.5,
    maximum_value = 3.0,
    order = "b"
  },
  {
    type = "bool-setting",
    name = "train-stop-item-color-blend-item-colors",
    setting_type = "runtime-global",
    default_value = false,
    order = "c"
  },
  {
    type = "bool-setting",
    name = "use-color-from-pipes-for-fluids",
    setting_type = "runtime-global",
    default_value = true,
    order = "d"
  },
  {
    type = "string-setting",
    name = "ignore-first-icon-in-train-stop-name",
    setting_type = "runtime-global",
    default_value = "passive-provider-chest;requester-chest"
  }
})
