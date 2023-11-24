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
	LoadoutReminder.TALENTS:InitTalentDB()
	LoadoutReminder.EQUIP:InitEquipDB()
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

function LoadoutReminder.MAIN:CheckAndShowGeneral()
	print("TLR: Check and Show General")
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)

	reminderFrame.content.bossInfo:Hide() -- do not show on reload info

	local currentTalentSet, assignedTalentSet = LoadoutReminder.TALENTS:CheckGeneralTalentSet()
	local currentAddonSet, assignedAddonSet = LoadoutReminder.ADDONS:CheckGeneralAddonSet()
	local currentEquipSet, assignedEquipSet = LoadoutReminder.EQUIP:CheckGeneralEquipSet()

	-- Update Talent Reminder
	if assignedTalentSet then
		print("Update Talent Reminder: " .. tostring(currentTalentSet) .. "/" .. tostring(assignedTalentSet))
		if currentTalentSet ~= nil then
			reminderFrame.content.talentFrame.info:SetText("Current Talent Set: \"" .. currentTalentSet .. "\"")
		else
			reminderFrame.content.talentFrame.info:SetText("Current Talent Set not recognized")
		end

		LoadoutReminder.TALENTS:UpdateLoadButtonMacro(assignedTalentSet)
	end

	-- if any loadout is to be reminded of -> show 
	if assignedTalentSet or assignedAddonSet or assignedEquipSet then
		reminderFrame:Show()
	end
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

	local CURRENT_SET = LoadoutReminder.TALENTS:GetCurrentSet()

	if CURRENT_SET == bossSet then
		-- set is already assigned, hide frame
		reminderFrame:Hide()
		return 
	end

	if CURRENT_SET ~= nil then
		reminderFrame.content.talentFrame.info:SetText("Current Talent Set: \"" .. CURRENT_SET .. "\"")
	else
		reminderFrame.content.talentFrame.info:SetText("Current Talent Set not recognized")
	end

	local bossName = LoadoutReminder.CONST.BOSS_NAMES[boss] -- TODO: Localizations
	if bossName then
		reminderFrame.content.bossInfo:Show()
		reminderFrame.content.bossInfo:SetText("Boss detected: " .. bossName)
	else
		reminderFrame.content.bossInfo:Hide()
	end

	LoadoutReminder.TALENTS:UpdateLoadButtonMacro(bossSet)

	reminderFrame:Show()
end

function LoadoutReminder.MAIN:PLAYER_ENTERING_WORLD(isLogIn, isReload)
		LoadoutReminder.MAIN:CheckAndShowGeneral()
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
			LoadoutReminder.MAIN:CheckAndShowGeneral()
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