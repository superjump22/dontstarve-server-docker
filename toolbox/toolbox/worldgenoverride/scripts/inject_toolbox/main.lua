require "constants"
local function export()
    local Levels = require('map/levels')
    local Customize = require('map/customize')
    Customize.ITEM_EXPORTS.atlas = nil
    Customize.ITEM_EXPORTS.grouplabel = nil
    Customize.ITEM_EXPORTS.widget_type = nil
    Customize.ITEM_EXPORTS.options_remap = nil
    Customize.ITEM_EXPORTS.key = function(item) return item.name end
    Customize.ITEM_EXPORTS.text = function(item)
        return STRINGS.UI.CUSTOMIZATIONSCREEN[string.upper(item.name)] or
            item.name
    end
    Customize.ITEM_EXPORTS.group_text = function(item)
        return STRINGS.UI.SANDBOXMENU
            ['CHOICE' .. string.upper(item.group.group_name)] or item.group.text
    end
    Customize.ITEM_EXPORTS.master_controlled = function(item) return item.master_controlled or false end
    Customize.ITEM_EXPORTS.order = function(item) return item.order or 0 end
    return {
        main = {
            forest = {
                settings_preset = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL, 'forest', true),
                worldgen_preset = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL, 'forest', true),
                settings_options = Customize.GetWorldSettingsOptions('forest', true),
                worldgen_options = Customize.GetWorldGenOptions('forest', true),
            },
            cave = {
                settings_preset = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL, 'cave', true),
                worldgen_preset = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL, 'cave', true),
                settings_options = Customize.GetWorldSettingsOptions('cave', true),
                worldgen_options = Customize.GetWorldGenOptions('cave', true),
            }
        },
        other = {
            forest = {
                settings_preset = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL, 'forest', true),
                worldgen_preset = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL, 'forest', true),
                settings_options = Customize.GetWorldSettingsOptions('forest', false),
                worldgen_options = Customize.GetWorldGenOptions('forest', false),
            },
            cave = {
                settings_preset = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL, 'cave', true),
                worldgen_preset = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL, 'cave', true),
                settings_options = Customize.GetWorldSettingsOptions('cave', false),
                worldgen_options = Customize.GetWorldGenOptions('cave', false),
            }
        },
    }
end
local out = {}
out.en = export(1)
LOC.SwapLanguage(LANGUAGE.CHINESE_S)
out.zh = export(2)
LOC.SwapLanguage(LANGUAGE.CHINESE_T)
out.zht = export(3)
local file = assert(io.open('worldgenoverride.json', "w"))
file:write(json.encode_compliant(out))
file:close()
Shutdown()
