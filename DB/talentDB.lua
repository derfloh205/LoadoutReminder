---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.DB
LoadoutReminder.DB = LoadoutReminder.DB

---@class LoadoutReminder.DB.CRAFTER : LoadoutReminder.DB.Repository
LoadoutReminder.DB.TALENTS = LoadoutReminder.DB:RegisterRepository()

---@alias SpecID number
---@alias TalentSetID number|string

function LoadoutReminder.DB.TALENTS:Init()
    if not LoadoutReminderDB.talentDB then
        ---@type LoadoutReminderDB.Database
        LoadoutReminderDB.talentDB = {
            version = 0,
            ---@class LoadoutReminderDB.talentDB.data
            data = {
                ---@type table<LoadoutReminder.InstanceTypes, table<LoadoutReminder.Difficulty, table<SpecID, TalentSetID>>>
                instanceSets = {},
                ---@type table<LoadoutReminder.Raids, table<LoadoutReminder.Raidboss, table<LoadoutReminder.Difficulty, table<SpecID, TalentSetID>>>>
                raidSets = {}
            },
        }
    end
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
---@param talentSetID TalentSetID
function LoadoutReminder.DB.TALENTS:SaveInstanceSet(instanceType, difficulty, specID, talentSetID)
    LoadoutReminderDB.talentDB.data.instanceSets[instanceType] =
        LoadoutReminderDB.talentDB.data.instanceSets[instanceType] or {}
    LoadoutReminderDB.talentDB.data.instanceSets[instanceType][difficulty] =
        LoadoutReminderDB.talentDB.data.instanceSets[instanceType][difficulty] or {}
    LoadoutReminderDB.talentDB.data.instanceSets[instanceType][difficulty][specID] = talentSetID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
---@return TalentSetID? talentSetID
function LoadoutReminder.DB.TALENTS:GetInstanceSet(instanceType, difficulty, specID)
    LoadoutReminderDB.talentDB.data.instanceSets[instanceType] =
        LoadoutReminderDB.talentDB.data.instanceSets[instanceType] or {}
    LoadoutReminderDB.talentDB.data.instanceSets[instanceType][difficulty] =
        LoadoutReminderDB.talentDB.data.instanceSets[instanceType][difficulty] or {}
    return LoadoutReminderDB.talentDB.data.instanceSets[instanceType][difficulty][specID]
end

---@param raid LoadoutReminder.Raids
---@param boss LoadoutReminder.Raidboss
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
---@param talentSetID TalentSetID
function LoadoutReminder.DB.TALENTS:SaveRaidBossSet(raid, boss, difficulty, specID, talentSetID)
    LoadoutReminderDB.talentDB.data.raidSets[raid] = LoadoutReminderDB.talentDB.data.raidSets[raid] or {}
    LoadoutReminderDB.talentDB.data.raidSets[raid][boss] =
        LoadoutReminderDB.talentDB.data.raidSets[raid][boss] or {}
    LoadoutReminderDB.talentDB.data.raidSets[raid][boss][difficulty] =
        LoadoutReminderDB.talentDB.data.raidSets[raid][boss][difficulty] or {}
    LoadoutReminderDB.talentDB.data.raidSets[raid][boss][difficulty][specID] = talentSetID
end

---@param raid LoadoutReminder.Raids
---@param boss LoadoutReminder.Raidboss
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
---@return TalentSetID? talentSetID
function LoadoutReminder.DB.TALENTS:GetRaidBossSet(raid, boss, difficulty, specID)
    LoadoutReminderDB.talentDB.data.raidSets[raid] = LoadoutReminderDB.talentDB.data.raidSets[raid] or {}
    LoadoutReminderDB.talentDB.data.raidSets[raid][boss] =
        LoadoutReminderDB.talentDB.data.raidSets[raid][boss] or {}
    LoadoutReminderDB.talentDB.data.raidSets[raid][boss][difficulty] =
        LoadoutReminderDB.talentDB.data.raidSets[raid][boss][difficulty] or {}
    return LoadoutReminderDB.talentDB.data.raidSets[raid][boss][difficulty][specID]
end

function LoadoutReminder.DB.TALENTS:Migrate()
    if LoadoutReminderDB.talentDB.version == 0 then
        -- migrate from old sv table structure
        if _G["LoadoutReminderDBV3"] then
            if _G["LoadoutReminderDBV3"].GENERAL then
                for difficulty, instanceTypeData in pairs(_G["LoadoutReminderDBV3"].GENERAL) do
                    for instanceType, data in pairs(instanceTypeData) do
                        if data.TALENTS then
                            for specID, talentSetID in pairs(data.TALENTS) do
                                self:SaveInstanceSet(instanceType, difficulty, specID, talentSetID)
                            end
                        end
                    end
                end
            end

            if _G["LoadoutReminderDBV3"].RAIDS then
                for raid, difficultyData in pairs(_G["LoadoutReminderDBV3"].RAIDS) do
                    for difficulty, bossData in pairs(difficultyData) do
                        for boss, data in pairs(bossData) do
                            if data.TALENTS then
                                for specID, talentSetID in pairs(data.TALENTS) do
                                    self:SaveRaidBossSet(raid, boss, difficulty, specID, talentSetID)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- LoadoutReminderDB.talentDB.version = 1
    end
end

function LoadoutReminder.DB.TALENTS:CleanUp()

end
