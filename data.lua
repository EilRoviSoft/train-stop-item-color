local item = {
    type = "selection-tool",
    name = "train-stop-color-tool",
    subgroup = "tool",
    order = "z[train-stop-color-tool]",

    icons = {
        {
            icon = "__train-stop-item-color__/graphics/icons/train-stop-item-color-x32.png",
            icon_size = 32,
        }
    },

    flags = { "only-in-cursor", "spawnable" },
    stack_size = 1,
    hidden = true,

    select = {
        border_color = { r = 0, g = 1, b = 0, a = 1 },
        mode = { "buildable-type", "same-force" },
        cursor_box_type = "entity",
        entity_type_filters = { "train-stop" }
    },

    alt_select = {
        border_color = { r = 0, g = 1, b = 0, a = 1 },
        mode = { "buildable-type", "same-force" },
        cursor_box_type = "entity",
        entity_type_filters = { "train-stop" }
    }
}

local shortcut = {
    type = "shortcut",
    name = "color-train-stops",
    action = "spawn-item",
    item_to_spawn = "train-stop-color-tool",
    order = "m[color-train-stops]",
    icon_size = 32,
    icon = "__train-stop-item-color__/graphics/icons/train-stop-item-color-x32.png",
    small_icon_size = 24,
    small_icon = "__train-stop-item-color__/graphics/icons/train-stop-item-color-x24.png",
	localised_name = {"shortcut-name.color-train-stops"}
}


data:extend { item, shortcut }
