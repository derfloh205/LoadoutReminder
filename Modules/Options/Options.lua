---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

LoadoutReminder.OPTIONS = {}
LoadoutReminder.OPTIONS.DROPDOWNS = {}
LoadoutReminder.OPTIONS.PERBOSSCHECKBOXES = {}
LoadoutReminder.OPTIONS.HELPICONS_DEFAULT_RAID = {}
LoadoutReminder.OPTIONS.HELPICONS_DEFAULT_DIFF = {}

function LoadoutReminder.OPTIONS:GetTalentsData()
    -- #### TALENTS
    ---@type number|string[]
    local talentSetIDs = LoadoutReminder.TALENTS:GetTalentSets()

    -- convert to dropdown data, always include starter build label
    local talentsDropdownData = {
        {
            label = LoadoutReminder.CONST.LABEL_NO_SET,
            value = nil
        },
        {
            label = LoadoutReminder.CONST.STARTER_BUILD,
            value = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID
        }
    }
    table.foreach(talentSetIDs, function(_, configID)
        local setName = LoadoutReminder.TALENTS:GetTalentSetNameByID(configID)
        table.insert(talentsDropdownData, {
            label = setName,
            value = configID,
        })
    end)
    return talentsDropdownData
end

function LoadoutReminder.OPTIONS:GetAddonsData()
    if not LoadoutReminder.ADDONS.AVAILABLE then
        return nil
    end
    local addonSets = LoadoutReminder.ADDONS:GetAddonSets()

    -- convert to dropdown data, always include starter build label
    local addonsDropdownData = {
        {
            label = LoadoutReminder.CONST.LABEL_NO_SET,
            value = nil
        }
    }

    table.foreach(addonSets, function(setName, _)
        table.insert(addonsDropdownData, {
            label = setName,
            value = setName,
        })
    end)
    return addonsDropdownData
end

function LoadoutReminder.OPTIONS:GetEquipData()
    local equipSets = LoadoutReminder.EQUIP:GetEquipSets()

    -- convert to dropdown data, always include starter build label
    local equipDropdownData = {
        {
            label = LoadoutReminder.CONST.LABEL_NO_SET,
            value = nil
        }
    }

    table.foreach(equipSets, function(_, setID)
        local setName = LoadoutReminder.EQUIP:GetEquipSetNameByID(setID)
        table.insert(equipDropdownData, {
            label = setName,
            value = setID,
        })
    end)
    return equipDropdownData
end

function LoadoutReminder.OPTIONS:GetSpecData()
    local specs = LoadoutReminder.SPEC:GetSpecSets()
    -- convert to dropdown data, always include starter build label
    local specDropdownData = {
        {
            label = LoadoutReminder.CONST.LABEL_NO_SET,
            value = nil
        }
    }

    table.foreach(specs, function(_, specID)
        local specName = specID and select(2, GetSpecializationInfoByID(specID)) or ""
        table.insert(specDropdownData, {
            label = specName,
            value = specID,
        })
    end)
    return specDropdownData
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

function LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss()
    local raid = LoadoutReminder.UTIL:GetCurrentRaid()
    if not raid then
        return false
    end
    local difficulty = LoadoutReminder.UTIL:GetInstanceDifficulty()
    if not difficulty then
        -- happens on first execution after going into a raid.. next exec should include difficulty
        return false
    end
    local optionKey = LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)

    return LoadoutReminder.DB.OPTIONS:Get("PER_BOSS_LOADOUTS")[optionKey]
end
