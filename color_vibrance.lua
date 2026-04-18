-- color_vibrance.lua
local M = {}

-- default values (will be overridden by settings)
local VIBRANCE_PUSH = 1.5
local SATURATION_BOOST = 1.5

local function clamp01(x)
    if x < 0 then return 0 end
    if x > 1 then return 1 end
    return x
end

local function rgb_to_hsv(r, g, b)
    local maxc = math.max(r, g, b)
    local minc = math.min(r, g, b)
    local v = maxc
    local delta = maxc - minc
    local s = 0
    if maxc > 0 then s = delta / maxc end
    local h = 0
    if delta > 0 then
        if maxc == r then
            h = (g - b) / delta
            if g < b then h = h + 6 end
        elseif maxc == g then
            h = (b - r) / delta + 2
        else
            h = (r - g) / delta + 4
        end
        h = h / 6
    end
    return h, s, v
end

local function hsv_to_rgb(h, s, v)
    if s == 0 then return v, v, v end
    h = h * 6
    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))
    i = i % 6
    if i == 0 then return v, t, p end
    if i == 1 then return q, v, p end
    if i == 2 then return p, v, t end
    if i == 3 then return p, q, v end
    if i == 4 then return t, p, v end
    return v, p, q
end

local function boost_vibrance(r, g, b)
    local avg = (r + g + b) / 3
    r = avg + (r - avg) * VIBRANCE_PUSH
    g = avg + (g - avg) * VIBRANCE_PUSH
    b = avg + (b - avg) * VIBRANCE_PUSH

    local h, s, v = rgb_to_hsv(r, g, b)
    s = math.min(1, s * SATURATION_BOOST)
    r, g, b = hsv_to_rgb(h, s, v)

    r = clamp01(r)
    g = clamp01(g)
    b = clamp01(b)

    return r, g, b
end

-- Merge function (same signature as before)
function M.merge(tbl, boost, dest)
    if type(tbl) ~= "table" then return end
    dest = dest or _G.ITEM_COLORS
    if type(dest) ~= "table" then
        error("color_vibrance.merge: destination table missing")
    end
    for k, v in pairs(tbl) do
        local r, g, b = v.r, v.g, v.b
        if boost then
            r, g, b = boost_vibrance(r, g, b)
        end
        dest[k] = { r = r, g = g, b = b }
    end
end

-- Allow runtime config to be set programmatically
function M.set_config(push, sat)
    if type(push) == "number" then VIBRANCE_PUSH = push end
    if type(sat) == "number" then SATURATION_BOOST = sat end
end

-- Read runtime-global settings and apply them
function M.apply_settings_from_game()
    -- settings.global is available in control stage
    local push_setting = settings.global["train-stop-item-color-vibrance-push"]
    local sat_setting  = settings.global["train-stop-item-color-saturation-boost"]
    if push_setting and sat_setting then
        M.set_config(push_setting.value, sat_setting.value)
    end
end

M.boost_vibrance = boost_vibrance
return M
