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

function LoadoutReminder.CHECK:CheckSituations()
    if LoadoutReminder.CHECK.sessionPause then return end

    -- check only when player is not in combat and only if everything was initialized
    if not LoadoutReminder.MAIN.READY or UnitAffectingCombat('player') then
        return
    end

    local activeInstanceReminders = LoadoutReminder.CHECK:CheckInstanceTypes()
    local activeBossReminders = LoadoutReminder.CHECK:CheckBoss()

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

---@return LoadoutReminder.ActiveReminders | nil
function LoadoutReminder.CHECK:CheckInstanceTypes()
    if LoadoutReminder.CHECK.sessionPause then return end

    local activeReminders = LoadoutReminder.ActiveReminders(false, false, false, false)

    if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
        return activeReminders
    end

    local instanceType = LoadoutReminder.UTIL:GetCurrentInstanceType()

    if LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss() then
        -- print("ic: has raid loadouts per boss")
        -- Hide ReminderFrames
        LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, nil,
            LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
        LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, nil,
            LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
        LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, nil,
            LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
        LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, nil,
            LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
        return activeReminders
    end
    -- print("Check Instance Reminders")
    local talentReminderInfo = LoadoutReminder.TALENTS:CheckInstanceTalentSet()
    local addonReminderInfo = (LoadoutReminder.ADDONS.AVAILABLE and LoadoutReminder.ADDONS:CheckInstanceAddonSet()) or
        nil
    local equipReminderInfo = LoadoutReminder.EQUIP:CheckInstanceEquipSet()
    local specReminderInfo = LoadoutReminder.SPEC:CheckInstanceSpecSet()

    --  print("talentReminderInfo: " .. tostring(talentReminderInfo))
    --  print("addonReminderInfo: " .. tostring(addonReminderInfo))
    --  print("equipReminderInfo: " .. tostring(equipReminderInfo))
    --  print("specReminderInfo: " .. tostring(specReminderInfo))


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

---@return LoadoutReminder.ActiveReminders | nil
function LoadoutReminder.CHECK:CheckBoss()
    if LoadoutReminder.CHECK.sessionPause then return end

    local activeReminders = LoadoutReminder.ActiveReminders(false, false, false, false)
    if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
        return activeReminders
    end

    -- no raid loadouts per boss -> do not remind
    if not LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss() then
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
    local boss = LoadoutReminder.CONST.BOSS_ID_MAP[npcID]

    if boss == nil then
        return activeReminders -- npc is no boss
    end

    local raid = LoadoutReminder.UTIL:GetCurrentRaid() -- or LoadoutReminder.CONST.RAIDS.AMIRDRASSIL -- DEBUG

    if not raid then
        return
    end
    -- print("check boss reminders..")
    local talentReminderInfo = LoadoutReminder.TALENTS:CheckBossTalentSet(raid, boss)
    local addonReminderInfo = (LoadoutReminder.ADDONS.AVAILABLE and LoadoutReminder.ADDONS:CheckBossAddonSet(raid, boss)) or
        nil
    local equipReminderInfo = LoadoutReminder.EQUIP:CheckBossEquipSet(raid, boss)
    local specReminderInfo = LoadoutReminder.SPEC:CheckBossSpecSet(raid, boss)

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
        LoadoutReminder.OPTIONS.FRAMES:ReloadDropdowns()
    end)
end

function LoadoutReminder.CHECK:TRAIT_CONFIG_CREATED()
    RunNextFrame(function()
        LoadoutReminder.CHECK:CheckSituations()
        LoadoutReminder.OPTIONS.FRAMES:ReloadDropdowns()
    end)
end

function LoadoutReminder.CHECK:TRAIT_CONFIG_DELETED()
    RunNextFrame(function()
        LoadoutReminder.CHECK:CheckSituations()
        LoadoutReminder.OPTIONS.FRAMES:ReloadDropdowns()
    end)
end

function LoadoutReminder.CHECK:TRAIT_CONFIG_UPDATED()
    RunNextFrame(function()
        LoadoutReminder.CHECK:CheckSituations()
        LoadoutReminder.OPTIONS.FRAMES:ReloadDropdowns()
    end)
end
