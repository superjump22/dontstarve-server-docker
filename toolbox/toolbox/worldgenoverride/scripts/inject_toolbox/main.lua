-- require "constants"
-- local lang_ids = { LANGUAGE.CHINESE_S, LANGUAGE.CHINESE_T }
-- LOC.SwapLanguage(lang_id)
local Customize = require 'map/customize'
Customize.ITEM_EXPORTS.master_controlled = function(item) return item.master_controlled or false end
Customize.ITEM_EXPORTS.order = function(item) return item.order or 0 end
local Levels = require 'map/levels'
local function GenerateWorldgenoverride(location, is_master_world)
    local path = nil
    if is_master_world then
        path = string.format('worldgenoverride_%s_master.json', location)
    else
        path = string.format('worldgenoverride_%s.json', location)
    end
    local out = {
        settings_preset = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL, location, true),
        worldgen_preset = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL, location, true),
        settings_options = Customize.GetWorldSettingsOptions(location, is_master_world),
        worldgen_options = Customize.GetWorldGenOptions(location, is_master_world),
    }
    local file = assert(io.open(path, "w"))
    file:write(json.encode_compliant(out))
    file:close()
end
GenerateWorldgenoverride('forest', true)
GenerateWorldgenoverride('forest', false)
GenerateWorldgenoverride('cave', true)
GenerateWorldgenoverride('cave', false)
Shutdown()