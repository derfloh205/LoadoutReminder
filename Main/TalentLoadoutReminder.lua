TalentLoadoutReminderAddonName, TalentLoadoutReminder = ...

TalentLoadoutReminder.MAIN = CreateFrame("Frame", "TalentLoadoutReminderAddon")
TalentLoadoutReminder.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
TalentLoadoutReminder.MAIN:RegisterEvent("ADDON_LOADED")
TalentLoadoutReminder.MAIN:RegisterEvent("PLAYER_LOGIN")
TalentLoadoutReminder.MAIN:RegisterEvent("PLAYER_LOGOUT")
TalentLoadoutReminder.MAIN:RegisterEvent("PLAYER_ENTERING_WORLD")
TalentLoadoutReminder.MAIN:RegisterEvent("TRAIT_CONFIG_UPDATED")
TalentLoadoutReminder.MAIN:RegisterEvent("CONFIG_COMMIT_FAILED")
TalentLoadoutReminder.MAIN:RegisterEvent("TRAIT_TREE_CHANGED")

TalentLoadoutReminder.MAIN.FRAMES = {}

TalentLoadoutReminderGGUIConfig = TalentLoadoutReminderGGUIConfig or {}

TalentLoadoutReminderDB = TalentLoadoutReminderDB or {
	DUNGEON = nil,
	OPENWORLD = nil,
	RAID = nil,
	BG = nil,
	ARENA = nil,
}

function TalentLoadoutReminder.MAIN:ADDON_LOADED(addon_name)
	if addon_name ~= TalentLoadoutReminderAddonName then
		return
	end

	TalentLoadoutReminder.OPTIONS:Init()
	TalentLoadoutReminder.REMINDER_FRAME.FRAMES:Init()	

	-- restore frame position
	local reminderFrame = TalentLoadoutReminder.GGUI:GetFrame(TalentLoadoutReminder.MAIN.FRAMES, TalentLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	reminderFrame:RestoreSavedConfig(UIParent)
end

---@return TraitConfigInfo[]
function TalentLoadoutReminder.MAIN:GetTalentSets()
	local specID = PlayerUtil.GetCurrentSpecID()

	local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)

	local talentSets = TalentLoadoutReminder.GUTIL:Map(configIDs, function (configID)
		return C_Traits.GetConfigInfo(configID)
	end)
	return talentSets
end

function TalentLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(set)
	local reminderFrame = TalentLoadoutReminder.GGUI:GetFrame(TalentLoadoutReminder.MAIN.FRAMES, TalentLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	-- hide frame if its visible
	reminderFrame:Hide()
end

function TalentLoadoutReminder.MAIN:CheckAndShow()
	local inInstance, instanceType = IsInInstance()

	local reminderFrame = TalentLoadoutReminder.GGUI:GetFrame(TalentLoadoutReminder.MAIN.FRAMES, TalentLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)

	local DUNGEON_SET = TalentLoadoutReminderDB["DUNGEON"]
	local RAID_SET = TalentLoadoutReminderDB["RAID"]
	local BG_SET = TalentLoadoutReminderDB["BG"]
	local ARENA_SET = TalentLoadoutReminderDB["ARENA"]
	local OPENWORLD_SET = TalentLoadoutReminderDB["OPENWORLD"]
	local SET_TO_LOAD = nil
	local CURRENT_SET = TalentLoadoutReminder.MAIN:GetCurrentSet()

	-- check if player went into a dungeon
	if inInstance and instanceType == 'party' then
		if instanceType == 'party' then
			if DUNGEON_SET == CURRENT_SET or DUNGEON_SET == nil then
				TalentLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(DUNGEON_SET)
				return
			end
			SET_TO_LOAD = DUNGEON_SET
		elseif instanceType == 'raid' then
			if RAID_SET == CURRENT_SET or RAID_SET == nil then
				TalentLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(RAID_SET)
				return
			end
			SET_TO_LOAD = RAID_SET
		elseif instanceType == 'pvp' then
			if BG_SET == CURRENT_SET or BG_SET == nil then
				TalentLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(BG_SET)
				return
			end
			SET_TO_LOAD = BG_SET
		elseif instanceType == 'arena' then
			if ARENA_SET == CURRENT_SET or ARENA_SET == nil then
				TalentLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(ARENA_SET)
				return
			end
			SET_TO_LOAD = ARENA_SET
		end
	elseif not inInstance then
		if OPENWORLD_SET == CURRENT_SET or OPENWORLD_SET == nil then
			TalentLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(OPENWORLD_SET)
			return
		end
		SET_TO_LOAD = OPENWORLD_SET
	end

	if CURRENT_SET ~= nil then
		reminderFrame.content.info:SetText("Current Talent Set: \"" .. CURRENT_SET .. "\"")
	else
		reminderFrame.content.info:SetText("Current Talent Set not recognized")
	end

	TalentLoadoutReminder.REMINDER_FRAME:UpdateLoadButtonMacro(SET_TO_LOAD)

	reminderFrame:Show()
end

--- find out what set is currently activated
function TalentLoadoutReminder.MAIN:GetCurrentSet()

	if C_ClassTalents.GetStarterBuildActive() then
		return TalentLoadoutReminder.CONST.STARTER_BUILD
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
		return configInfo.name
	else
		return nil -- no set selected yet?
	end
end


function TalentLoadoutReminder.MAIN:PLAYER_ENTERING_WORLD(isLogIn, isReload)
		TalentLoadoutReminder.MAIN:CheckAndShow()
end

function TalentLoadoutReminder.MAIN:PLAYER_LOGIN()
	SLASH_TALENTLOADOUTREMINDER1 = "/talentloadoutreminder"
	SLASH_TALENTLOADOUTREMINDER2 = "/tlor"
	SlashCmdList["TALENTLOADOUTREMINDER"] = function(input)

		input = SecureCmdOptionParse(input)
		if not input then return end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if command == "config" then
			InterfaceOptionsFrame_OpenToCategory(TalentLoadoutReminder.OPTIONS.optionsPanel)
		end

		if command == "check" then 
			TalentLoadoutReminder.MAIN:CheckAndShow()
		end

		if command == "" then
			print("Talent LoadoutReminder Help")
			print("/tlor or /talentloadoutreminder can be used for following commands")
			print("/tlor -> show help text")
			print("/tlor config -> show options panel")
			print("/tlor check -> if configured check current player situation")
		end
	end
end

function TalentLoadoutReminder.MAIN:TRAIT_CONFIG_UPDATED()
	TalentLoadoutReminder.MAIN:CheckAndShow()
	-- make another check slightly delayed
	C_Timer.After(1, function ()
		TalentLoadoutReminder.MAIN:CheckAndShow()
	end)
end

function TalentLoadoutReminder.MAIN:CONFIG_COMMIT_FAILED()
	TalentLoadoutReminder.MAIN:CheckAndShow()
end

function TalentLoadoutReminder.MAIN:TRAIT_TREE_CHANGED() 
	TalentLoadoutReminder.MAIN:CheckAndShow()
end