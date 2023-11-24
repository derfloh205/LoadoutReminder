LoadoutReminderAddonName, LoadoutReminder = ...

LoadoutReminder.MAIN = CreateFrame("Frame", "LoadoutReminderAddon")
LoadoutReminder.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.MAIN:RegisterEvent("ADDON_LOADED")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_LOGIN")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_LOGOUT")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_ENTERING_WORLD")
LoadoutReminder.MAIN:RegisterEvent("TRAIT_CONFIG_UPDATED")
LoadoutReminder.MAIN:RegisterEvent("CONFIG_COMMIT_FAILED")
LoadoutReminder.MAIN:RegisterEvent("TRAIT_TREE_CHANGED")
-- LoadoutReminder.MAIN:RegisterEvent("ZONE_CHANGED")
-- LoadoutReminder.MAIN:RegisterEvent("ZONE_CHANGED_INDOORS")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_TARGET_CHANGED")

LoadoutReminder.MAIN.FRAMES = {}

LoadoutReminderGGUIConfig = LoadoutReminderGGUIConfig or {}

LoadoutReminderDB = LoadoutReminderDB or {
	DUNGEON = nil,
	OPENWORLD = nil,
	RAID = nil,
	BG = nil,
	ARENA = nil,
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

---@return TraitConfigInfo[]
function LoadoutReminder.MAIN:GetTalentSets()
	local specID = PlayerUtil.GetCurrentSpecID()

	local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)

	local talentSets = LoadoutReminder.GUTIL:Map(configIDs, function (configID)
		return C_Traits.GetConfigInfo(configID)
	end)
	return talentSets
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

	local DUNGEON_SET = LoadoutReminderDB["DUNGEON"]
	local RAID_SET = LoadoutReminderDB["RAID"]
	local BG_SET = LoadoutReminderDB["BG"]
	local ARENA_SET = LoadoutReminderDB["ARENA"]
	local OPENWORLD_SET = LoadoutReminderDB["OPENWORLD"]
	local SET_TO_LOAD = nil
	local CURRENT_SET = LoadoutReminder.MAIN:GetCurrentSet()

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

	local bossSet = LoadoutReminderBossDB[boss]

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

--- find out what set is currently activated
function LoadoutReminder.MAIN:GetCurrentSet()

	if C_ClassTalents.GetStarterBuildActive() then
		return LoadoutReminder.CONST.STARTER_BUILD
	end

	-- from wowpedia
	local function GetSelectedLoadoutConfigID()
		local lastSelected = PlayerUtil.GetCurrentSpecID() and C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID())
		local selectionID = ClassTalentFrame and ClassTalentFrame.TalentsTab and ClassTalentFrame.TalentsTab.LoadoutDropDown and ClassTalentFrame.TalentsTab.LoadoutDropDown.GetSelectionID and ClassTalentFrame.TalentsTab.LoadoutDropDown:GetSelectionID()
	
		-- the priority in authoritativeness is [default UI's dropdown] > [API] > ['ActiveConfigID'] > nil
		return selectionID or lastSelected or C_ClassTalents.GetActiveConfigID() or nil -- nil happens when you don't have any spec selected, e.g. on a freshly created character
	end

	local configID = GetSelectedLoadoutConfigID()

	if configID then
		local configInfo = C_Traits.GetConfigInfo(configID);
		if configInfo then
			return configInfo.name
		end
		-- otherwise wtf?
		return nil
	else
		return nil -- no set selected yet?
	end
end


function LoadoutReminder.MAIN:PLAYER_ENTERING_WORLD(isLogIn, isReload)
		LoadoutReminder.MAIN:CheckAndShowReload()
end

function LoadoutReminder.MAIN:PLAYER_LOGIN()
	SLASH_LoadoutReminder1 = "/LoadoutReminder"
	SLASH_LoadoutReminder2 = "/tlor"
	SlashCmdList["LoadoutReminder"] = function(input)

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
			print("Talent LoadoutReminder Help")
			print("/tlor or /LoadoutReminder can be used for following commands")
			print("/tlor -> show help text")
			print("/tlor config -> show options panel")
			print("/tlor check -> if configured check current player situation")
		end
	end
end

function LoadoutReminder.MAIN:TRAIT_CONFIG_UPDATED()
	LoadoutReminder.MAIN:CheckAndShowReload()
	-- make another check slightly delayed
	C_Timer.After(1, function ()
		LoadoutReminder.MAIN:CheckAndShowReload()
	end)
end

function LoadoutReminder.MAIN:CONFIG_COMMIT_FAILED()
	LoadoutReminder.MAIN:CheckAndShowReload()
end

function LoadoutReminder.MAIN:TRAIT_TREE_CHANGED() 
	LoadoutReminder.MAIN:CheckAndShowReload()
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