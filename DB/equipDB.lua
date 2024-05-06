---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.DB
LoadoutReminder.DB = LoadoutReminder.DB

---@class LoadoutReminder.DB.EQUIP : LoadoutReminder.DB.Repository
LoadoutReminder.DB.EQUIP = LoadoutReminder.DB:RegisterRepository()

---@alias EquipSetID number|string

function LoadoutReminder.DB.EQUIP:Init()
    if not LoadoutReminderDB.equipDB then
        ---@type LoadoutReminderDB.Database
        LoadoutReminderDB.equipDB = {
            version = 0,
            ---@class LoadoutReminderDB.equipDB.data
            data = {
                ---@type table<LoadoutReminder.InstanceTypes, table<LoadoutReminder.Difficulty, EquipSetID>>
                instanceSets = {},
                ---@type table<LoadoutReminder.Raids, table<LoadoutReminder.Raidboss, table<LoadoutReminder.Difficulty, EquipSetID>>>
                raidSets = {}
            },
        }
    end
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@param equipSetID EquipSetID
function LoadoutReminder.DB.EQUIP:SaveInstanceSet(instanceType, difficulty, equipSetID)
    LoadoutReminderDB.equipDB.data.instanceSets[instanceType] =
        LoadoutReminderDB.equipDB.data.instanceSets[instanceType] or {}
    LoadoutReminderDB.equipDB.data.instanceSets[instanceType][difficulty] = equipSetID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@return EquipSetID? equipSetID
function LoadoutReminder.DB.EQUIP:GetInstanceSet(instanceType, difficulty)
    LoadoutReminderDB.equipDB.data.instanceSets[instanceType] =
        LoadoutReminderDB.equipDB.data.instanceSets[instanceType] or {}
    return LoadoutReminderDB.equipDB.data.instanceSets[instanceType][difficulty]
end

---@param raid LoadoutReminder.Raids
---@param boss LoadoutReminder.Raidboss
---@param difficulty LoadoutReminder.Difficulty
---@param equipSetID EquipSetID
function LoadoutReminder.DB.EQUIP:SaveRaidBossSet(raid, boss, difficulty, equipSetID)
    LoadoutReminderDB.equipDB.data.raidSets[raid] = LoadoutReminderDB.equipDB.data.raidSets[raid] or {}
    LoadoutReminderDB.equipDB.data.raidSets[raid][boss] =
        LoadoutReminderDB.equipDB.data.raidSets[raid][boss] or {}
    LoadoutReminderDB.equipDB.data.raidSets[raid][boss][difficulty] = equipSetID
end

---@param raid LoadoutReminder.Raids
---@param boss LoadoutReminder.Raidboss
---@param difficulty LoadoutReminder.Difficulty
---@return EquipSetID? equipSetID
function LoadoutReminder.DB.EQUIP:GetRaidBossSet(raid, boss, difficulty)
    LoadoutReminderDB.equipDB.data.raidSets[raid] = LoadoutReminderDB.equipDB.data.raidSets[raid] or {}
    LoadoutReminderDB.equipDB.data.raidSets[raid][boss] =
        LoadoutReminderDB.equipDB.data.raidSets[raid][boss] or {}
    return LoadoutReminderDB.equipDB.data.raidSets[raid][boss][difficulty]
end

function LoadoutReminder.DB.EQUIP:Migrate()
    if LoadoutReminderDB.equipDB.version < 2 then
        self:ClearAll()
        LoadoutReminderDB.equipDB.version = 2
    end
end

function LoadoutReminder.DB.EQUIP:ClearAll()
    wipe(LoadoutReminderDB.equipDB.data.instanceSets)
    wipe(LoadoutReminderDB.equipDB.data.raidSets)
end

function LoadoutReminder.DB.EQUIP:CleanUp()

end
