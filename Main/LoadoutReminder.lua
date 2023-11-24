LoadoutReminderAddonName, LoadoutReminder = ...

LoadoutReminder.MAIN = CreateFrame("Frame")
LoadoutReminder.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.MAIN:RegisterEvent("ADDON_LOADED")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_LOGIN")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_LOGOUT")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_ENTERING_WORLD")
-- LoadoutReminder.MAIN:RegisterEvent("ZONE_CHANGED")
-- LoadoutReminder.MAIN:RegisterEvent("ZONE_CHANGED_INDOORS")
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

LoadoutReminderBossDB = LoadoutReminderBossDB or {}

function LoadoutReminder.MAIN:ADDON_LOADED(addon_name)
	if addon_name ~= LoadoutReminderAddonName then
		return
	end

	LoadoutReminder.OPTIONS:Init()
	LoadoutReminder.REMINDER_FRAME.FRAMES:Init()	

	-- restore frame position
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	reminderFrame:RestoreSavedConfig(UIParent)
end

function LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(set)
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	-- hide frame if its visible
	reminderFrame:Hide()
end

function LoadoutReminder.MAIN:CheckAndShowReload()
	local inInstance, instanceType = IsInInstance()

	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)

	reminderFrame.content.bossInfo:Hide() -- do not show on reload info

	local DUNGEON_SET = LoadoutReminderDB.TALENTS.GENERAL["DUNGEON"]
	local RAID_SET = LoadoutReminderDB.TALENTS.GENERAL["RAID"]
	local BG_SET = LoadoutReminderDB.TALENTS.GENERAL["BG"]
	local ARENA_SET = LoadoutReminderDB.TALENTS.GENERAL["ARENA"]
	local OPENWORLD_SET = LoadoutReminderDB.TALENTS.GENERAL["OPENWORLD"]
	local SET_TO_LOAD = nil
	local CURRENT_SET = LoadoutReminder.TALENTS:GetCurrentSet()

	-- check if player went into a dungeon
	if inInstance and instanceType == 'party' then
		if instanceType == 'party' then
			if DUNGEON_SET == CURRENT_SET or DUNGEON_SET == nil then
				LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(DUNGEON_SET)
				return
			end
			SET_TO_LOAD = DUNGEON_SET
		elseif instanceType == 'raid' then
			if RAID_SET == CURRENT_SET or RAID_SET == nil then
				LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(RAID_SET)
				return
			end
			SET_TO_LOAD = RAID_SET
		elseif instanceType == 'pvp' then
			if BG_SET == CURRENT_SET or BG_SET == nil then
				LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(BG_SET)
				return
			end
			SET_TO_LOAD = BG_SET
		elseif instanceType == 'arena' then
			if ARENA_SET == CURRENT_SET or ARENA_SET == nil then
				LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(ARENA_SET)
				return
			end
			SET_TO_LOAD = ARENA_SET
		end
	elseif not inInstance then
		if OPENWORLD_SET == CURRENT_SET or OPENWORLD_SET == nil then
			LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(OPENWORLD_SET)
			return
		end
		SET_TO_LOAD = OPENWORLD_SET
	end

	if CURRENT_SET ~= nil then
		reminderFrame.content.info:SetText("Current Talent Set: \"" .. CURRENT_SET .. "\"")
	else
		reminderFrame.content.info:SetText("Current Talent Set not recognized")
	end

	LoadoutReminder.REMINDER_FRAME:UpdateLoadButtonMacro(SET_TO_LOAD)

	reminderFrame:Show()
end

function LoadoutReminder.MAIN:CheckAndShowNewTarget()
	
	-- get name of player's target
	local npcID = LoadoutReminder.MAIN:GetTargetNPCID()
	if not npcID then
		return -- no target
	end
	-- check npcID for boss
	local boss = LoadoutReminder.CONST.BOSS_ID_MAP[npcID]
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)

	if boss == nil then
		return -- npc is no boss
	end

	local bossSet = LoadoutReminderDB.TALENTS.BOSS[boss]

	if bossSet == nil then
		return -- no set assigned to this boss yet
	end

	local CURRENT_SET = LoadoutReminder.MAIN:GetCurrentSet()

	if CURRENT_SET == bossSet then
		-- set is already assigned, hide frame
		reminderFrame:Hide()
		return 
	end

	if CURRENT_SET ~= nil then
		reminderFrame.content.info:SetText("Current Talent Set: \"" .. CURRENT_SET .. "\"")
	else
		reminderFrame.content.info:SetText("Current Talent Set not recognized")
	end

	local bossName = LoadoutReminder.CONST.BOSS_NAMES[boss] -- TODO: Localizations
	if bossName then
		reminderFrame.content.bossInfo:Show()
		reminderFrame.content.bossInfo:SetText("Boss detected: " .. bossName)
	else
		reminderFrame.content.bossInfo:Hide()
	end

	LoadoutReminder.REMINDER_FRAME:UpdateLoadButtonMacro(bossSet)

	reminderFrame:Show()
end

function LoadoutReminder.MAIN:PLAYER_ENTERING_WORLD(isLogIn, isReload)
		LoadoutReminder.MAIN:CheckAndShowReload()
end

function LoadoutReminder.MAIN:PLAYER_LOGIN()
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
			LoadoutReminder.MAIN:CheckAndShowReload()
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
	LoadoutReminder.MAIN:CheckAndShowNewTarget()
end

function LoadoutReminder.MAIN:GetTargetNPCID()
    if UnitExists("target") then
        local targetGUID = UnitGUID("target")
        local _, _, _, _, _, npcID = strsplit("-", targetGUID)

        return tonumber(npcID)
    end

    return nil
end