-- top-level requires (safe)
local function safe_require(name)
    local ok, res = pcall(require, name)
    if ok and type(res) == "table" then
        return res
    end
    return nil
end

-- Cache color tables at parse time
local colors_vanilla_generated    = safe_require("colors.vanilla-generated")
local colors_vanilla_custom       = safe_require("colors.vanilla-custom")

local colors_space_age_generated  = safe_require("colors.space-age-generated")
local colors_maraxsis_generated   = safe_require("colors.maraxsis-generated")

local colors_krastorio2_generated = safe_require("colors.krastorio2-generated")

-- require your vibrance module at top-level too
local color_vibrance              = safe_require("color_vibrance") or error("color_vibrance module missing")


ITEM_COLORS = {} -- global used by the rest of your mod

local function rebuild_item_colors()
    -- apply runtime settings to vibrance module
    color_vibrance.apply_settings_from_game()

    -- clear existing
    for k in pairs(ITEM_COLORS) do ITEM_COLORS[k] = nil end

    -- Merge using cached tables (no require calls here)
    if colors_vanilla_generated then
        color_vibrance.merge(colors_vanilla_generated, true, ITEM_COLORS)
    end
    if colors_vanilla_custom then
        color_vibrance.merge(colors_vanilla_custom, false, ITEM_COLORS)
    end

    if script.active_mods["space-age"] then
        if colors_space_age_generated then
            color_vibrance.merge(colors_space_age_generated, true, ITEM_COLORS)
        end
    end

    if script.active_mods["maraxsis"] then
        if colors_maraxsis_generated then
            color_vibrance.merge(colors_maraxsis_generated, true, ITEM_COLORS)
        end
    end

    if script.active_mods["Krastorio2"] and colors_krastorio2_generated then
        color_vibrance.merge(colors_krastorio2_generated, true, ITEM_COLORS)
    end

    if settings.global["use-color-from-pipes-for-fluids"].value then
        override_fluid_colors = {}

        for _, proto in pairs(prototypes.fluid) do
            override_fluid_colors[proto.name] = {
                r = proto.base_color.r,
                g = proto.base_color.g,
                b = proto.base_color.b
            }
        end

        color_vibrance.merge(override_fluid_colors, true, ITEM_COLORS)
    end
end


local function split(str, sep)
    local result = {}
    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(result, part)
    end
    return result
end

local ignore_first_list = {}

local function rebuild_ignore_first_list()
    ignore_first_list = {}

    for _, it in ipairs(split(settings.global["ignore-first-icon-in-train-stop-name"].value, ";")) do
        ignore_first_list[it] = true
    end
end


rebuild_item_colors()
rebuild_ignore_first_list()

script.on_configuration_changed(function(data)
    rebuild_item_colors()
    rebuild_ignore_first_list()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == "train-stop-item-color-vibrance-push" or event.setting == "train-stop-item-color-saturation-boost" then
        rebuild_item_colors()
        rebuild_ignore_first_list()
    end
end)

local function color_train_stop(entity)
    if not (entity and entity.valid and entity.type == "train-stop") then return end

    local name = entity.backer_name

    -- Find all item and fluid tags
    local items = {}
    for item in name:gmatch("%[item=([%w%-_]+)%]") do
        if not (#items == 0 and ignore_first_list[item]) then
            items[#items + 1] = item
        end
    end
    for fluid in name:gmatch("%[fluid=([%w%-_]+)%]") do
        items[#items + 1] = fluid
    end

    if #items == 0 then return end

    --game.print(serpent.line(ignore_first_list))
    --game.print(serpent.line(items))

    -- Read setting
    local blend = settings.global["train-stop-item-color-blend-item-colors"].value

    -- If NOT blending, use the first matching color and exit early
    if not blend then
        local first = items[1]
        local c = ITEM_COLORS[first]
        if not c then return end

        entity.color = {
            r = c.r,
            g = c.g,
            b = c.b,
            a = 1
        }
        return
    end

    -- Blend colors (default behaviour)
    local r, g, b = 0, 0, 0
    local count = 0

    for _, item in ipairs(items) do
        local c = ITEM_COLORS[item]
        if c then
            r = r + c.r
            g = g + c.g
            b = b + c.b
            count = count + 1
        end
    end

    if count == 0 then return end

    entity.color = {
        r = r / count,
        g = g / count,
        b = b / count,
        a = 1
    }
end


script.on_event(defines.events.on_player_selected_area, function(event)
    if event.item ~= "train-stop-color-tool" then return end

    for _, entity in pairs(event.entities) do
        color_train_stop(entity)
    end
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
    if event.item ~= "train-stop-color-tool" then return end

    for _, entity in pairs(event.entities) do
        color_train_stop(entity)
    end
end)
