---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

local GUTIL = LoadoutReminder.GUTIL

---@class LoadoutReminder.CHECK : Frame
LoadoutReminder.CHECK = GUTIL:CreateRegistreeForEvents(
    {
        "PLAYER_TARGET_CHANGED",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_LEAVE_COMBAT",
        "TRAIT_CONFIG_LIST_UPDATED",
        "TRAIT_CONFIG_CREATED",
        "TRAIT_CONFIG_DELETED",
        "TRAIT_CONFIG_UPDATED",
    })

LoadoutReminder.CHECK.sessionPause = false


local BOSSES = LoadoutReminder.CONST.BOSS_IDS
local DIFF = LoadoutReminder.CONST.DIFFICULTY
local RAIDS = LoadoutReminder.CONST.RAIDS

function LoadoutReminder.CHECK:CheckSituations()
    if LoadoutReminder.CHECK.sessionPause then return end

    -- check only when player is not in combat and only if everything was initialized
    if not LoadoutReminder.INIT.READY or UnitAffectingCombat('player') then
        return
    end

    local difficulty = LoadoutReminder.UTIL:GetInstanceDifficulty() or LoadoutReminder.CONST.DIFFICULTY.DEFAULT
    local specID = LoadoutReminder.UTIL:GetPlayerSpecID()
    local raid = LoadoutReminder.UTIL:GetCurrentRaid() -- or LoadoutReminder.CONST.RAIDS.AMIRDRASSIL -- DEBUG

    print("Checking situations for ")
    print("difficulty: " .. difficulty)
    print("specID: " .. specID)

    local activeInstanceReminders = LoadoutReminder.CHECK:CheckInstanceTypes(raid, difficulty, specID)
    local activeBossReminders = LoadoutReminder.CHECK:CheckBoss(raid, difficulty, specID)
    local combinedActiveCount = LoadoutReminder.ActiveReminders:GetCombinedActiveRemindersCount({ activeInstanceReminders,
        activeBossReminders })

    -- if any reminder is triggered: show frame, otherwise hide
    -- print('combinedActiveCount: ' .. tostring(combinedActiveCount))
    -- print('activeInstanceReminders: ' .. tostring(activeInstanceReminders:GetCount()))
    -- print('activeBossReminders: ' .. tostring(activeBossReminders:GetCount()))
    if combinedActiveCount > 0 then
        -- set status of frame depending on how many things are to be reminded of
        LoadoutReminder.UTIL:UpdateReminderFrame(true,
            LoadoutReminder.ActiveReminders:GetCombinedActiveRemindersCount({ activeInstanceReminders,
                activeBossReminders }))
    else
        LoadoutReminder.UTIL:UpdateReminderFrame(false)
    end
end

---@param raid LoadoutReminder.Raids?
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
---@return LoadoutReminder.ActiveReminders | nil
function LoadoutReminder.CHECK:CheckInstanceTypes(raid, difficulty, specID)
    if LoadoutReminder.CHECK.sessionPause then return end

    local activeReminders = LoadoutReminder.ActiveReminders(false, false, false, false)

    if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
        return activeReminders
    end

    local talentReminderInfo, addonReminderInfo, equipReminderInfo, specReminderInfo
    local instanceType = LoadoutReminder.UTIL:GetCurrentInstanceType()

    if raid then
        local perBossLoadouts = LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss(raid, difficulty)
        if not perBossLoadouts then
            talentReminderInfo =
                LoadoutReminder.TALENTS:CheckBossTalentSet(raid, BOSSES.DEFAULT.DEFAULT, difficulty, specID) or
                LoadoutReminder.TALENTS:CheckBossTalentSet(raid, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT, specID) or
                LoadoutReminder.TALENTS:CheckBossTalentSet(RAIDS.DEFAULT, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT, specID)
            if LoadoutReminder.ADDONS.AVAILABLE then
                addonReminderInfo =
                    LoadoutReminder.ADDONS:CheckBossAddonSet(raid, BOSSES.DEFAULT.DEFAULT, difficulty) or
                    LoadoutReminder.ADDONS:CheckBossAddonSet(raid, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT) or
                    LoadoutReminder.ADDONS:CheckBossAddonSet(RAIDS.DEFAULT, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT)
            end
            equipReminderInfo =
                LoadoutReminder.EQUIP:CheckBossEquipSet(raid, BOSSES.DEFAULT.DEFAULT, difficulty) or
                LoadoutReminder.EQUIP:CheckBossEquipSet(raid, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT) or
                LoadoutReminder.EQUIP:CheckBossEquipSet(RAIDS.DEFAULT, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT)
            specReminderInfo =
                LoadoutReminder.SPEC:CheckBossSpecSet(raid, BOSSES.DEFAULT.DEFAULT, difficulty, specID) or
                LoadoutReminder.SPEC:CheckBossSpecSet(raid, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT, specID) or
                LoadoutReminder.SPEC:CheckBossSpecSet(RAIDS.DEFAULT, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT, specID)
        end
    else
        -- Check different reminder types and fallback to default values
        talentReminderInfo =
            LoadoutReminder.TALENTS:CheckInstanceTalentSet(instanceType, difficulty, specID) or
            LoadoutReminder.TALENTS:CheckInstanceTalentSet(instanceType, DIFF.DEFAULT, specID)
        if LoadoutReminder.ADDONS.AVAILABLE then
            addonReminderInfo =
                LoadoutReminder.ADDONS:CheckInstanceAddonSet(instanceType, difficulty) or
                LoadoutReminder.ADDONS:CheckInstanceAddonSet(instanceType, DIFF.DEFAULT)
        end
        equipReminderInfo =
            LoadoutReminder.EQUIP:CheckInstanceEquipSet(instanceType, difficulty) or
            LoadoutReminder.EQUIP:CheckInstanceEquipSet(instanceType, DIFF.DEFAULT)
        specReminderInfo =
            LoadoutReminder.SPEC:CheckInstanceSpecSet(instanceType, difficulty, specID) or
            LoadoutReminder.SPEC:CheckInstanceSpecSet(instanceType, DIFF.DEFAULT, specID)
    end

    -- print("talentReminderInfo: " .. tostring(talentReminderInfo))
    -- print("addonReminderInfo: " .. tostring(addonReminderInfo))
    -- print("equipReminderInfo: " .. tostring(equipReminderInfo))
    -- print("specReminderInfo: " .. tostring(specReminderInfo))


    -- Update Talent Reminder
    LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, talentReminderInfo,
        LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])

    -- Update Addon Reminder
    LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, addonReminderInfo,
        LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])

    -- Update Equip Reminder
    LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, equipReminderInfo,
        LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])

    -- Update Spec Reminder
    LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, specReminderInfo,
        LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])

    return LoadoutReminder.ActiveReminders(
        talentReminderInfo and not talentReminderInfo:IsAssignedSet(),
        addonReminderInfo and not addonReminderInfo:IsAssignedSet(),
        equipReminderInfo and not equipReminderInfo:IsAssignedSet(),
        specReminderInfo and not specReminderInfo:IsAssignedSet()
    )
end

---@param raid LoadoutReminder.Raids
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
---@return LoadoutReminder.ActiveReminders | nil
function LoadoutReminder.CHECK:CheckBoss(raid, difficulty, specID)
    if LoadoutReminder.CHECK.sessionPause then return end
    if not raid then return end

    local activeReminders = LoadoutReminder.ActiveReminders(false, false, false, false)
    if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
        return activeReminders
    end

    -- no raid loadouts per boss -> do not remind
    if not LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss(raid, difficulty) then
        -- Hide ReminderFrames
        LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, nil, "", true)
        LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, nil, "", true)
        LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, nil, "", true)
        LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, nil, "", true)
        return activeReminders
    end

    -- get name of player's target
    local npcID = LoadoutReminder.UTIL:GetTargetNPCID()
    if not npcID then
        return activeReminders -- no target
    end
    -- check npcID for boss
    local bossData = LoadoutReminder.CONST.BOSS_ID_MAP[npcID] and
        LoadoutReminder.CONST.BOSS_ID_MAP[npcID] --[[@as LoadoutReminder.RaidBossData]]


    if bossData == nil then
        return activeReminders -- npc is no boss
    end

    local boss = bossData.boss

    -- print("check boss reminders..")
    -- Check different reminder types and fallback to defaults
    local talentReminderInfo =
        LoadoutReminder.TALENTS:CheckBossTalentSet(raid, boss, difficulty, specID) or
        LoadoutReminder.TALENTS:CheckBossTalentSet(raid, boss, DIFF.DEFAULT, specID) or
        LoadoutReminder.TALENTS:CheckBossTalentSet(raid, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT, specID) or
        LoadoutReminder.TALENTS:CheckBossTalentSet(RAIDS.DEFAULT, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT, specID)
    local addonReminderInfo
    if LoadoutReminder.ADDONS.AVAILABLE then
        addonReminderInfo =
            LoadoutReminder.ADDONS:CheckBossAddonSet(raid, boss, difficulty) or
            LoadoutReminder.ADDONS:CheckBossAddonSet(raid, boss, DIFF.DEFAULT) or
            LoadoutReminder.ADDONS:CheckBossAddonSet(raid, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT) or
            LoadoutReminder.ADDONS:CheckBossAddonSet(RAIDS.DEFAULT, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT)
    end
    local equipReminderInfo =
        LoadoutReminder.EQUIP:CheckBossEquipSet(raid, boss, difficulty) or
        LoadoutReminder.EQUIP:CheckBossEquipSet(raid, boss, DIFF.DEFAULT) or
        LoadoutReminder.EQUIP:CheckBossEquipSet(raid, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT) or
        LoadoutReminder.EQUIP:CheckBossEquipSet(RAIDS.DEFAULT, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT)
    local specReminderInfo =
        LoadoutReminder.SPEC:CheckBossSpecSet(raid, boss, difficulty, specID) or
        LoadoutReminder.SPEC:CheckBossSpecSet(raid, boss, DIFF.DEFAULT, specID) or
        LoadoutReminder.SPEC:CheckBossSpecSet(raid, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT, specID) or
        LoadoutReminder.SPEC:CheckBossSpecSet(RAIDS.DEFAULT, BOSSES.DEFAULT.DEFAULT, DIFF.DEFAULT, specID)

    -- print("talentReminderInfo: " .. tostring(talentReminderInfo))
    -- print("addonReminderInfo: " .. tostring(addonReminderInfo))
    -- print("equipReminderInfo: " .. tostring(equipReminderInfo))
    -- print("specReminderInfo: " .. tostring(specReminderInfo))

    -- Update Talent Reminder
    LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, talentReminderInfo,
        LoadoutReminder.CONST.BOSS_NAMES[boss], true)

    -- Update Addon Reminder
    LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, addonReminderInfo,
        LoadoutReminder.CONST.BOSS_NAMES[boss], true)

    -- Update Equip Reminder
    LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, equipReminderInfo,
        LoadoutReminder.CONST.BOSS_NAMES[boss], true)

    -- Update Spec Reminder
    LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, specReminderInfo,
        LoadoutReminder.CONST.BOSS_NAMES[boss], true)

    return LoadoutReminder.ActiveReminders(
        talentReminderInfo and not talentReminderInfo:IsAssignedSet(),
        addonReminderInfo and not addonReminderInfo:IsAssignedSet(),
        equipReminderInfo and not equipReminderInfo:IsAssignedSet(),
        specReminderInfo and not specReminderInfo:IsAssignedSet()
    )
end

-- EVENTS
function LoadoutReminder.CHECK:PLAYER_TARGET_CHANGED()
    LoadoutReminder.CHECK:CheckSituations()
end

function LoadoutReminder.CHECK:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
    -- only when entering/exiting an instance, not on login or reload (thats where ADDON_LOADED fires)
    if isInitialLogin or isReloadingUi then
        return
    end
    LoadoutReminder.CHECK:CheckSituations()
end

function LoadoutReminder.CHECK:PLAYER_LEAVE_COMBAT()
    LoadoutReminder.CHECK:CheckSituations()
end

function LoadoutReminder.CHECK:TRAIT_CONFIG_LIST_UPDATED()
    RunNextFrame(function()
        LoadoutReminder.CHECK:CheckSituations()
        LoadoutReminder.OPTIONS.FRAMES:UpdateSetListDisplay()
    end)
end

function LoadoutReminder.CHECK:TRAIT_CONFIG_CREATED()
    RunNextFrame(function()
        LoadoutReminder.CHECK:CheckSituations()
        LoadoutReminder.OPTIONS.FRAMES:UpdateSetListDisplay()
    end)
end

function LoadoutReminder.CHECK:TRAIT_CONFIG_DELETED()
    RunNextFrame(function()
        LoadoutReminder.CHECK:CheckSituations()
        LoadoutReminder.OPTIONS.FRAMES:UpdateSetListDisplay()
    end)
end

function LoadoutReminder.CHECK:TRAIT_CONFIG_UPDATED()
    RunNextFrame(function()
        LoadoutReminder.CHECK:CheckSituations()
        LoadoutReminder.OPTIONS.FRAMES:UpdateSetListDisplay()
    end)
end
