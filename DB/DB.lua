---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

local GUTIL = LoadoutReminder.GUTIL

---@class LoadoutReminder.DB
LoadoutReminder.DB = {}

---@class LoadoutReminder.DB.Repository
---@field Init function
---@field ClearAll function
---@field Migrate function
---@field CleanUp function

---@class LoadoutReminderDB.Database
---@field version number
---@field data table

---@class LoadoutReminderDB
LoadoutReminderDB = LoadoutReminderDB or {}

---@type LoadoutReminder.DB.Repository[]
LoadoutReminder.DB.repositories = {}

---@return LoadoutReminder.DB.Repository
function LoadoutReminder.DB:RegisterRepository()
    ---@type LoadoutReminder.DB.Repository
    local repository = {
        Init = function() end,
        Migrate = function() end,
        ClearAll = function() end,
        CleanUp = function() end,
    }
    tinsert(LoadoutReminder.DB.repositories, repository)
    return repository
end

function LoadoutReminder.DB:Init()
    for _, repository in ipairs(self.repositories) do
        repository:Init()
        repository:Migrate()
        repository:CleanUp()
    end

    LoadoutReminder.DB:PostInitCleanUp()
end

function LoadoutReminder.DB:PostInitCleanUp()
    if _G["LoadoutReminderDBV3"] then
        _G["LoadoutReminderDBV3"] = nil
    end
end

function LoadoutReminder.DB:ClearAll()
    for _, repository in ipairs(self.repositories) do
        repository:ClearAll()
    end
end
