---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.DB
LoadoutReminder.DB = LoadoutReminder.DB

---@class LoadoutReminder.DB.ADDONS : LoadoutReminder.DB.Repository
LoadoutReminder.DB.ADDONS = LoadoutReminder.DB:RegisterRepository()

---@alias AddonSetID string|number

function LoadoutReminder.DB.ADDONS:Init()
    if not LoadoutReminderDB.addonDB then
        ---@type LoadoutReminderDB.Database
        LoadoutReminderDB.addonDB = {
            version = 0,
            ---@class LoadoutReminderDB.addonDB.data
            data = {
                ---@type table<LoadoutReminder.InstanceTypes, table<LoadoutReminder.Difficulty, AddonSetID>>
                instanceSets = {},
                ---@type table<LoadoutReminder.Raids, table<LoadoutReminder.Raidboss, table<LoadoutReminder.Difficulty, AddonSetID>>>
                raidSets = {}
            },
        }
    end
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@param addonSetID AddonSetID
function LoadoutReminder.DB.ADDONS:SaveInstanceSet(instanceType, difficulty, addonSetID)
    LoadoutReminderDB.addonDB.data.instanceSets[instanceType] =
        LoadoutReminderDB.addonDB.data.instanceSets[instanceType] or {}
    LoadoutReminderDB.addonDB.data.instanceSets[instanceType][difficulty] = addonSetID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@return AddonSetID? addonSetID
function LoadoutReminder.DB.ADDONS:GetInstanceSet(instanceType, difficulty)
    LoadoutReminderDB.addonDB.data.instanceSets[instanceType] =
        LoadoutReminderDB.addonDB.data.instanceSets[instanceType] or {}
    return LoadoutReminderDB.addonDB.data.instanceSets[instanceType][difficulty]
end

---@param raid LoadoutReminder.Raids
---@param boss LoadoutReminder.Raidboss
---@param difficulty LoadoutReminder.Difficulty
---@param addonSetID AddonSetID
function LoadoutReminder.DB.ADDONS:SaveRaidBossSet(raid, boss, difficulty, addonSetID)
    LoadoutReminderDB.addonDB.data.raidSets[raid] = LoadoutReminderDB.addonDB.data.raidSets[raid] or {}
    LoadoutReminderDB.addonDB.data.raidSets[raid][boss] =
        LoadoutReminderDB.addonDB.data.raidSets[raid][boss] or {}
    LoadoutReminderDB.addonDB.data.raidSets[raid][boss][difficulty] = addonSetID
end

---@param raid LoadoutReminder.Raids
---@param boss LoadoutReminder.Raidboss
---@param difficulty LoadoutReminder.Difficulty
---@return AddonSetID? addonSetID
function LoadoutReminder.DB.ADDONS:GetRaidBossSet(raid, boss, difficulty)
    LoadoutReminderDB.addonDB.data.raidSets[raid] = LoadoutReminderDB.addonDB.data.raidSets[raid] or {}
    LoadoutReminderDB.addonDB.data.raidSets[raid][boss] =
        LoadoutReminderDB.addonDB.data.raidSets[raid][boss] or {}
    return LoadoutReminderDB.addonDB.data.raidSets[raid][boss][difficulty]
end

function LoadoutReminder.DB.ADDONS:Migrate()
    if LoadoutReminderDB.addonDB.version == 0 then
        -- migrate from old sv table structure
        if _G["LoadoutReminderDBV3"] then
            if _G["LoadoutReminderDBV3"].GENERAL then
                for difficulty, instanceTypeData in pairs(_G["LoadoutReminderDBV3"].GENERAL) do
                    for instanceType, data in pairs(instanceTypeData) do
                        if data.ADDONS then
                            self:SaveInstanceSet(instanceType, difficulty, data.ADDONS)
                        end
                    end
                end
            end

            if _G["LoadoutReminderDBV3"].RAIDS then
                for difficulty, raidData in pairs(_G["LoadoutReminderDBV3"].RAIDS) do
                    for raid, bossData in pairs(raidData) do
                        for boss, data in pairs(bossData) do
                            if data.ADDONS then
                                self:SaveRaidBossSet(raid, boss, difficulty, data.ADDONS)
                            end
                        end
                    end
                end
            end
        end

        LoadoutReminderDB.addonDB.version = 1
    end
end

function LoadoutReminder.DB.ADDONS:CleanUp()

end
