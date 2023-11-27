LoadoutReminderAddonName, LoadoutReminder = ...

LoadoutReminder.MAIN = CreateFrame("Frame")
LoadoutReminder.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.MAIN:RegisterEvent("ADDON_LOADED")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_TARGET_CHANGED")

LoadoutReminder.MAIN.FRAMES = {}

LoadoutReminderGGUIConfig = LoadoutReminderGGUIConfig or {}

LoadoutReminderDB = LoadoutReminderDB or {
	TALENTS = {
		GENERAL = {},
		BOSS = {},
	},
	ADDONS = {
		GENERAL = {},
		BOSS = {},
	},
	EQUIP = {
		GENERAL = {},
		BOSS = {},
	},
}

LoadoutReminderOptions = LoadoutReminderOptions or {
	TALENTS = {
		RAIDS_PER_BOSS = {}
	}
}

function LoadoutReminder.MAIN:Init()
	if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
		-- poll until info is available
		C_Timer.After(LoadoutReminder.CONST.INIT_POLL_INTERVAL, LoadoutReminder.MAIN.Init)
		return	
	end

	LoadoutReminder.MAIN:InitializeSlashCommands()
	LoadoutReminder.TALENTS:InitTalentDB()
	LoadoutReminder.EQUIP:InitEquipDB()
	LoadoutReminder.OPTIONS:Init()
	LoadoutReminder.REMINDER_FRAME.FRAMES:Init()	

	-- restore frame position
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	reminderFrame:RestoreSavedConfig(UIParent)

	-- Make first check after everything is loaded
	LoadoutReminder.MAIN.CheckSituations()
end

function LoadoutReminder.MAIN:ADDON_LOADED(addon_name)
	if addon_name ~= LoadoutReminderAddonName then
		return
	end
	-- init as soon as player specialization is available -- polling
	LoadoutReminder.MAIN:Init()
end

function LoadoutReminder.MAIN.CheckSituations()
	local instanceTypeReminder = LoadoutReminder.MAIN:CheckInstanceTypes()
	local bossReminder = LoadoutReminder.MAIN:CheckTargetForBoss()

	-- if any reminder is triggered: show frame, otherwise hide
	if instanceTypeReminder or bossReminder then
		LoadoutReminder.UTIL:ToggleFrame(true)
	else
		LoadoutReminder.UTIL:ToggleFrame(false)
	end
end

function LoadoutReminder.MAIN:CheckInstanceTypes()
	--print("TLR: Check and Show General")

	if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
		return
	end

	local instanceType = LoadoutReminder.UTIL:GetCurrentInstanceType()
	local talentReminderInfo = LoadoutReminder.TALENTS:CheckInstanceTalentSet()
	-- local addonReminderInfo = LoadoutReminder.ADDONS:CheckInstanceAddonSet()
	-- local equipReminderInfo = LoadoutReminder.EQUIP:CheckInstanceEquipSet()

	-- Update Talent Reminder
	if talentReminderInfo then
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(talentReminderInfo, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
	end

	-- if any loadout is to be reminded of -> show 
	if (talentReminderInfo and not talentReminderInfo:IsAssignedSet()) or 
		(addonReminderInfo and not addonReminderInfo:IsAssignedSet()) or
		(equipReminderInfo and not equipReminderInfo:IsAssignedSet()) then
		return true
	end

	return false
end

function LoadoutReminder.MAIN:CheckTargetForBoss()
	if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
		return false
	end

	-- only check if this is the current raid is activated per boss
	if not LoadoutReminder.TALENTS:HasRaidTalentsPerBoss() then
		return false
	end


	-- get name of player's target
	local npcID = LoadoutReminder.MAIN:GetTargetNPCID()
	if not npcID then
		return false -- no target
	end
	-- check npcID for boss
	local boss = LoadoutReminder.CONST.BOSS_ID_MAP[npcID]

	if boss == nil then
		return false -- npc is no boss
	end

	local bossSet = LoadoutReminderDB.TALENTS.BOSS[boss]

	if bossSet == nil then
		return false -- no set assigned to this boss yet
	end

	local CURRENT_SET = LoadoutReminder.TALENTS:GetCurrentSet()

	-- if CURRENT_SET == bossSet then
	-- 	-- correct set assigned, do not need to change instance type set
	-- 	return false 
	-- end

	local macroText = LoadoutReminder.TALENTS:GetMacroTextBySet(bossSet)
	local reminderInfo = LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, 'Detected Boss: ', macroText, CURRENT_SET, bossSet)

	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(reminderInfo, LoadoutReminder.CONST.BOSS_NAMES[boss])

	-- only give an update for boss detected if its not the same set
	return not reminderInfo:IsAssignedSet()
end

function LoadoutReminder.MAIN:InitializeSlashCommands()
	SLASH_LOADOUTREMINDER1 = "/loadoutreminder"
	SLASH_LOADOUTREMINDER2 = "/lor"
	SlashCmdList["LOADOUTREMINDER"] = function(input)

		input = SecureCmdOptionParse(input)
		if not input then return end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if command == "config" then
			InterfaceOptionsFrame_OpenToCategory(LoadoutReminder.OPTIONS.optionsPanel)
		end

		if command == "check" then 
			LoadoutReminder.MAIN:CheckInstanceTypes()
		end

		if command == "" then
			print("LoadoutReminder Help")
			print("/lor or /loadoutreminder can be used for following commands")
			print("/lor -> show help text")
			print("/lor config -> show options panel")
			print("/lor check -> if configured check current player situation")
		end
	end
end

function LoadoutReminder.MAIN:PLAYER_TARGET_CHANGED() 
	LoadoutReminder.MAIN.CheckSituations()
end

function LoadoutReminder.MAIN:GetTargetNPCID()
    if UnitExists("target") then
        local targetGUID = UnitGUID("target")
        local _, _, _, _, _, npcID = strsplit("-", targetGUID)

        return tonumber(npcID)
    end

    return nil
end