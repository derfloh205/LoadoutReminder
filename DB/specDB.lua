---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.DB
LoadoutReminder.DB = LoadoutReminder.DB

---@class LoadoutReminder.DB.SPEC : LoadoutReminder.DB.Repository
LoadoutReminder.DB.SPEC = LoadoutReminder.DB:RegisterRepository()

function LoadoutReminder.DB.SPEC:Init()
    if not LoadoutReminderDB.specDB then
        ---@type LoadoutReminderDB.Database
        LoadoutReminderDB.specDB = {
            version = 0,
            ---@class LoadoutReminderDB.specDB.data
            data = {
                ---@type table<LoadoutReminder.InstanceTypes, table<LoadoutReminder.Difficulty, SpecID>>
                instanceSets = {},
                ---@type table<LoadoutReminder.Raids, table<LoadoutReminder.Raidboss, table<LoadoutReminder.Difficulty, SpecID>>>
                raidSets = {}
            },
        }
    end
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
function LoadoutReminder.DB.SPEC:SaveInstanceSet(instanceType, difficulty, specID)
    LoadoutReminderDB.specDB.data.instanceSets[instanceType] =
        LoadoutReminderDB.specDB.data.instanceSets[instanceType] or {}
    LoadoutReminderDB.specDB.data.instanceSets[instanceType][difficulty] = specID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@return SpecID? specID
function LoadoutReminder.DB.SPEC:GetInstanceSet(instanceType, difficulty)
    LoadoutReminderDB.specDB.data.instanceSets[instanceType] =
        LoadoutReminderDB.specDB.data.instanceSets[instanceType] or {}
    return LoadoutReminderDB.specDB.data.instanceSets[instanceType][difficulty]
end

---@param raid LoadoutReminder.Raids
---@param boss LoadoutReminder.Raidboss
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
function LoadoutReminder.DB.SPEC:SaveRaidBossSet(raid, boss, difficulty, specID)
    LoadoutReminderDB.specDB.data.raidSets[raid] = LoadoutReminderDB.specDB.data.raidSets[raid] or {}
    LoadoutReminderDB.specDB.data.raidSets[raid][boss] =
        LoadoutReminderDB.specDB.data.raidSets[raid][boss] or {}
    LoadoutReminderDB.specDB.data.raidSets[raid][boss][difficulty] = specID
end

---@param raid LoadoutReminder.Raids
---@param boss LoadoutReminder.Raidboss
---@param difficulty LoadoutReminder.Difficulty
---@return SpecID? specID
function LoadoutReminder.DB.SPEC:GetRaidBossSet(raid, boss, difficulty)
    LoadoutReminderDB.specDB.data.raidSets[raid] = LoadoutReminderDB.specDB.data.raidSets[raid] or {}
    LoadoutReminderDB.specDB.data.raidSets[raid][boss] =
        LoadoutReminderDB.specDB.data.raidSets[raid][boss] or {}
    return LoadoutReminderDB.specDB.data.raidSets[raid][boss][difficulty]
end

function LoadoutReminder.DB.SPEC:Migrate()
    if LoadoutReminderDB.specDB.version < 2 then
        self:ClearAll()
        LoadoutReminderDB.specDB.version = 2
    end
end

function LoadoutReminder.DB.SPEC:ClearAll()
    wipe(LoadoutReminderDB.specDB.data.instanceSets)
    wipe(LoadoutReminderDB.specDB.data.raidSets)
end

function LoadoutReminder.DB.SPEC:CleanUp()

end
