---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

local GUTIL = LoadoutReminder.GUTIL

local f = GUTIL:GetFormatter()

LoadoutReminder.OPTIONS = {}
LoadoutReminder.OPTIONS.DROPDOWNS = {}
LoadoutReminder.OPTIONS.PERBOSSCHECKBOXES = {}

---@return LoadoutReminder.SingleColumnFrameList.Data[]
function LoadoutReminder.OPTIONS:GetTalentsSelectionData()
    ---@type number|string[]
    local talentSetIDs = LoadoutReminder.TALENTS:GetTalentSets()

    -- convert to dropdown data, always include starter build label
    local selectionData = {
        {
            label = f.grey(LoadoutReminder.CONST.LABEL_NO_SET),
            value = nil
        },
        {
            label = f.bb(LoadoutReminder.CONST.STARTER_BUILD),
            value = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID
        }
    }
    table.foreach(talentSetIDs, function(_, configID)
        local setName = LoadoutReminder.TALENTS:GetTalentSetNameByID(configID)
        table.insert(selectionData, {
            label = setName,
            value = configID,
        })
    end)
    return selectionData
end

---@return LoadoutReminder.SingleColumnFrameList.Data[]

function LoadoutReminder.OPTIONS:GetAddonsSelectionData()
    if not LoadoutReminder.ADDONS.AVAILABLE then
        return nil
    end
    local addonSets = LoadoutReminder.ADDONS:GetAddonSets()

    local selectionData = {
        {
            label = f.grey(LoadoutReminder.CONST.LABEL_NO_SET),
            value = nil
        }
    }

    table.foreach(addonSets, function(setName, _)
        table.insert(selectionData, {
            label = setName,
            value = setName,
        })
    end)
    return selectionData
end

---@return LoadoutReminder.SingleColumnFrameList.Data[]
function LoadoutReminder.OPTIONS:GetEquipSelectionData()
    local equipSets = LoadoutReminder.EQUIP:GetEquipSets()

    local selectionData = {
        {
            label = f.grey(LoadoutReminder.CONST.LABEL_NO_SET),
            value = nil
        }
    }

    table.foreach(equipSets, function(_, setID)
        local setName = LoadoutReminder.EQUIP:GetEquipSetNameByID(setID)
        table.insert(selectionData, {
            label = setName,
            value = setID,
        })
    end)
    return selectionData
end

---@return LoadoutReminder.SingleColumnFrameList.Data[]
function LoadoutReminder.OPTIONS:GetSpecializationSelectionData()
    local specs = LoadoutReminder.SPEC:GetSpecSets()
    -- convert to dropdown data, always include starter build label
    local selectionData = {
        {
            label = f.grey(LoadoutReminder.CONST.LABEL_NO_SET),
            value = nil
        }
    }

    table.foreach(specs, function(_, specID)
        local specName = specID and select(2, GetSpecializationInfoByID(specID)) or ""
        table.insert(selectionData, {
            label = specName,
            value = specID,
        })
    end)
    return selectionData
end

function LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)
    return difficulty .. "_" .. raid .. "_PerBoss"
end

function LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType)
    local difficulty = "DEFAULT"
    if LoadoutReminder.UTIL:InstanceTypeSupportsDifficulty(instanceType) then
        difficulty = LoadoutReminder.OPTIONS.difficultyDropdown.selectedValue
    end
    return difficulty
end

---@param raid LoadoutReminder.Raids
function LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss(raid, difficulty)
    if not raid then
        return false
    end

    if not difficulty then
        -- happens on first execution after going into a raid.. next exec should include difficulty
        return false
    end
    local optionKey = LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)

    return LoadoutReminder.DB.OPTIONS:Get("PER_BOSS_LOADOUTS")[optionKey]
end

function LoadoutReminder.OPTIONS:SaveSelection()
    local content = LoadoutReminder.OPTIONS.frame.content --[[@as LoadoutReminder.OPTIONS.FRAME.CONTENT]]
    local selectedReminderType = content.reminderTypesList.selectedRow
        .selectedValue --[[@as LoadoutReminder.ReminderTypes]]
    local specID = LoadoutReminder.UTIL:GetPlayerSpecID()
    local selectedGeneralType = content.generalList.selectedRow and
        content.generalList.selectedRow.selectedValue --[[@as LoadoutReminder.GeneralReminderTypes]]
    local selectedInstanceType = content.instanceTypesList.selectedRow and
        content.instanceTypesList.selectedRow.selectedValue --[[@as LoadoutReminder.InstanceTypes]]
    local selectedDifficulty = content.difficultyList.selectedRow and
        content.difficultyList.selectedRow.selectedValue --[[@as LoadoutReminder.Difficulty]]
    local selectedRaid = content.raidList.selectedRow and
        content.raidList.selectedRow.selectedValue --[[@as LoadoutReminder.Raids]]
    local selectedBoss = content.raidBossList.selectedRow and
        content.raidBossList.selectedRow.selectedValue --[[@as LoadoutReminder.Raidboss]]

    local selectedSetID = content.setList.selectedRow and
        content.setList.selectedRow.selectedValue --[[@as string|number]]

    if selectedGeneralType == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.INSTANCE_TYPES then
        if selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.ADDONS then
            LoadoutReminder.DB.ADDONS:SaveInstanceSet(selectedInstanceType, selectedDifficulty, selectedSetID)
        elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.EQUIP then
            LoadoutReminder.DB.EQUIP:SaveInstanceSet(selectedInstanceType, selectedDifficulty, selectedSetID)
        elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.TALENTS then
            LoadoutReminder.DB.TALENTS:SaveInstanceSet(selectedInstanceType, selectedDifficulty, selectedSetID, specID)
        elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.SPEC then
            LoadoutReminder.DB.SPEC:SaveInstanceSet(selectedInstanceType, selectedDifficulty, selectedSetID)
        end
    elseif selectedGeneralType == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.RAID_BOSSES then
        if selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.ADDONS then
            LoadoutReminder.DB.ADDONS:SaveRaidBossSet(selectedRaid, selectedBoss, selectedDifficulty, selectedSetID)
        elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.EQUIP then
            LoadoutReminder.DB.EQUIP:SaveRaidBossSet(selectedRaid, selectedBoss, selectedDifficulty, selectedSetID)
        elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.TALENTS then
            LoadoutReminder.DB.TALENTS:SaveRaidBossSet(selectedRaid, selectedBoss, selectedDifficulty, selectedSetID,
                specID)
        elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.SPEC then
            LoadoutReminder.DB.SPEC:SaveRaidBossSet(selectedRaid, selectedBoss, selectedDifficulty, selectedSetID)
        end
    end
end
