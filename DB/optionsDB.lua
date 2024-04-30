---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.DB
LoadoutReminder.DB = LoadoutReminder.DB

---@class LoadoutReminder.DB.OPTIONS : LoadoutReminder.DB.Repository
LoadoutReminder.DB.OPTIONS = LoadoutReminder.DB:RegisterRepository()

function LoadoutReminder.DB.OPTIONS:Init()
    if not LoadoutReminderDB.optionsDB then
        ---@type LoadoutReminderDB.Database
        LoadoutReminderDB.optionsDB = {
            version = 0,
            ---@type table<LoadoutReminder.Const.Options, any>
            data = {},
        }
    end
end

---@param option LoadoutReminder.Const.Options
---@param value any
function LoadoutReminder.DB.OPTIONS:Save(option, value)
    LoadoutReminderDB.optionsDB.data[option] = value
end

---@param option LoadoutReminder.Const.Options
---@return any value
function LoadoutReminder.DB.OPTIONS:Get(option)
    return LoadoutReminderDB.optionsDB.data[option] or LoadoutReminder.CONST.OPTION_DEFAULTS[option]
end

function LoadoutReminder.DB.OPTIONS:Migrate()
    if LoadoutReminderDB.optionsDB.version == 0 then
        -- migrate from old sv table structure
        if _G["LoadoutReminderOptionsV2"] then
            LoadoutReminderDB.optionsDB.data[LoadoutReminder.CONST.OPTIONS.GGUI_CONFIG] =
                _G["LoadoutReminderGGUIConfig"] or
                LoadoutReminder.CONST.OPTION_DEFAULTS[LoadoutReminder.CONST.OPTIONS.GGUI_CONFIG]
            LoadoutReminderDB.optionsDB.data[LoadoutReminder.CONST.OPTIONS.LIBDB_CONFIG] =
                _G["LoadoutReminderLibIconDB"] or
                LoadoutReminder.CONST.OPTION_DEFAULTS[LoadoutReminder.CONST.OPTIONS.LIBDB_CONFIG]
            LoadoutReminderDB.optionsDB.data[LoadoutReminder.CONST.OPTIONS.LIBDB_CONFIG] =
                _G["LoadoutReminderLibIconDB"] or
                LoadoutReminder.CONST.OPTION_DEFAULTS[LoadoutReminder.CONST.OPTIONS.LIBDB_CONFIG]
            LoadoutReminderDB.optionsDB.data[LoadoutReminder.CONST.OPTIONS.EQUIP_RAIDS_PER_BOSS] = LoadoutReminder.CONST
            .OPTION_DEFAULTS[LoadoutReminder.CONST.OPTIONS.EQUIP_RAIDS_PER_BOSS]
            LoadoutReminderDB.optionsDB.data[LoadoutReminder.CONST.OPTIONS.SPEC_RAIDS_PER_BOSS] = LoadoutReminder.CONST
            .OPTION_DEFAULTS[LoadoutReminder.CONST.OPTIONS.SPEC_RAIDS_PER_BOSS]
            LoadoutReminderDB.optionsDB.data[LoadoutReminder.CONST.OPTIONS.ADDONS_RAIDS_PER_BOSS] = LoadoutReminder
            .CONST.OPTION_DEFAULTS[LoadoutReminder.CONST.OPTIONS.ADDONS_RAIDS_PER_BOSS]
            LoadoutReminderDB.optionsDB.data[LoadoutReminder.CONST.OPTIONS.TALENT_RAIDS_PER_BOSS] = LoadoutReminder
            .CONST.OPTION_DEFAULTS[LoadoutReminder.CONST.OPTIONS.TALENT_RAIDS_PER_BOSS]
        end

        --LoadoutReminderDB.optionsDB.version = 1
    end
end

function LoadoutReminder.DB.OPTIONS:CleanUp()

end
