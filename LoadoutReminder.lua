-- Talent Version

local STARTER_BUILD = "Starter Build"

local addon = CreateFrame("Frame", "TalentLoadoutReminderAddon")
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_LOGOUT")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("TRAIT_CONFIG_UPDATED")
addon:RegisterEvent("CONFIG_COMMIT_FAILED")
addon:RegisterEvent("TRAIT_TREE_CHANGED")

local ConfigNameToIDMAP = {}

addon.defaultDB = {
	DUNGEON = nil,
	OPENWORLD = nil,
	RAID = nil,
	BG = nil,
	ARENA = nil,
	CURRENT_SET = nil
}

local last_current_set = nil
local isUpdatingLoadout = false
local loadingSet = nil
local changingFromStarterSet = false

function addon:TRAIT_CONFIG_UPDATED(_)
	if isUpdatingLoadout and loadingSet ~= nil then
		isUpdatingLoadout = false
		--print("talent was changed WITH loadoutreminder, set is now: " .. loadingSet)
		TalentLoadoutReminderFrame:Hide()	
		TalentLoadoutReminderDB["CURRENT_SET"] = loadingSet
		--print("you know what.. always update the dropdown! thx blizz")
		--print("selectionID: " .. ConfigNameToIDMAP[loadingSet])
		ClassTalentFrame.TalentsTab.LoadoutDropDown:SetSelectionID(ConfigNameToIDMAP[loadingSet])
	else
		--print("loadout was changed without loadoutreminder")
		if changingFromStarterSet then
			--print("coming from starter set..")
			changingFromStarterSet = false
		end
		addon:saveCurrentSetFromDropDownSelection() 
		addon:checkAndShow()
	end
end

function addon:TRAIT_TREE_CHANGED(_) 
 	-- I dont care, just update current set
 	last_current_set = TalentLoadoutReminderDB["CURRENT_SET"]
	if last_current_set == STARTER_BUILD then
		--print("changing from starter set..")
		changingFromStarterSet = true
	end
	--print("update last current set")
 	--addon:saveCurrentSetFromDropDownSelection() 
 end

function addon:CONFIG_COMMIT_FAILED()
	if last_current_set then
		-- reset current set to last set if there was a current set
		TalentLoadoutReminderDB["CURRENT_SET"] = last_current_set
		last_current_set = nil
		isUpdatingLoadout = false
		loadingSet = nil
		--print("commit failed")
		addon:checkAndShow()
	end
end

function addon:saveCurrentSetFromDropDownSelection() 
	local configID = addon:getTalentUICurrentSelectedLoadout()
		if configID ~= -2 and configID ~= nil then
			local name = C_Traits.GetConfigInfo(addon:getTalentUICurrentSelectedLoadout()).name
			TalentLoadoutReminderDB["CURRENT_SET"] = name
		elseif configID == -2 then
			--print("we got ourselves a starter build here!")
			TalentLoadoutReminderDB["CURRENT_SET"] = STARTER_BUILD
		end
end

function addon:getTalentUICurrentSelectedLoadout()
	return ClassTalentFrame.TalentsTab.LoadoutDropDown.lastValidSelectionID
end

function addon:getTalentSets()
	local talentSets = {STARTER_BUILD}
	local configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
	ConfigNameToIDMAP = {}
	ConfigNameToIDMAP[STARTER_BUILD] = -2
	for i, configID in ipairs(configIDs) do
		local configInfo = C_Traits.GetConfigInfo(configID)
		if configInfo ~= nil then
			table.insert(talentSets, configInfo.name)
			ConfigNameToIDMAP[configInfo.name] = configID
		end
	end
	return talentSets
end

function addon:ADDON_LOADED(addon_name)
	if addon_name == 'TalentLoadoutReminder' then
		LoadAddOn("Blizzard_ClassTalentUI")
		addon:loadDefaultDB()
		addon:initOptions()
		addon:initLoadoutReminderFrame()
	end
end

function addon:getCurrentSet()
	return TalentLoadoutReminderDB["CURRENT_SET"]
end

function addon:isSetLoaded(setName) 
	local currentSet = addon:getCurrentSet()
	return currentSet == setName
end

function addon:printAlreadyLoadedMessage(set)
	if set == nil then
		print("TLOR: Talentset not assigned yet. Type /tlor config to configure")
	else
		print("TLOR: Talentset already loaded: " .. set)
	end
	
end

function addon:checkAndShow()

	local current_set = addon.getCurrentSet()

	if current_set == nil then
		print("TLOR: Talent configuration does not differ from the default set")
		return
	end

	inInstance, instanceType = IsInInstance()

	local DUNGEON_SET = TalentLoadoutReminderDB["DUNGEON"]
	local RAID_SET = TalentLoadoutReminderDB["RAID"]
	local BG_SET = TalentLoadoutReminderDB["BG"]
	local ARENA_SET = TalentLoadoutReminderDB["ARENA"]
	local OPENWORLD_SET = TalentLoadoutReminderDB["OPENWORLD"]
	local SET_TO_LOAD = nil
	-- check if player went into a dungeon
	if inInstance and instanceType == 'party' then
		if instanceType == 'party' then
			if addon:isSetLoaded(DUNGEON_SET) or DUNGEON_SET == nil then
				addon:printAlreadyLoadedMessage(DUNGEON_SET)
				TalentLoadoutReminderFrame:Hide()
				return
			end
			SET_TO_LOAD = DUNGEON_SET
		elseif instanceType == 'raid' then
			if addon:isSetLoaded(RAID_SET) or RAID_SET == nil then
				addon:printAlreadyLoadedMessage(RAID_SET)
				TalentLoadoutReminderFrame:Hide()
				return
			end
			SET_TO_LOAD = RAID_SET
		elseif instanceType == 'pvp' then
			if addon:isSetLoaded(BG_SET) or BG_SET == nil then
				addon:printAlreadyLoadedMessage(BG_SET)
				TalentLoadoutReminderFrame:Hide()
				return
			end
			SET_TO_LOAD = BG_SET
		elseif instanceType == 'arena' then
			if addon:isSetLoaded(ARENA_SET) or ARENA_SET == nil then
				addon:printAlreadyLoadedMessage(ARENA_SET)
				TalentLoadoutReminderFrame:Hide()
				return
			end
			SET_TO_LOAD = ARENA_SET
		end
	elseif not inInstance then
		if addon:isSetLoaded(OPENWORLD_SET) or OPENWORLD_SET == nil then
			addon:printAlreadyLoadedMessage(OPENWORLD_SET)
			TalentLoadoutReminderFrame:Hide()
			return
		end
		SET_TO_LOAD = OPENWORLD_SET
	end
	local _ = addon:getTalentSets() -- refresh map
	local currentSet = addon:getCurrentSet()
	if ConfigNameToIDMAP[currentSet] == nil then
		-- only the case when handling a deleted set.. which shows as default set
		currentSet = currentSet .. " (deleted)"
	end
	TalentLoadoutReminderFrame.ContentFrame.text:SetText("Current Talent Set: \"" .. currentSet .. "\"")

	TalentLoadSetButton:SetScript("OnClick", function(self) 
		local canChange, canAdd, changeError = C_ClassTalents.CanChangeTalents()
		if canChange then
			--ClassTalentHelper.SwitchToLoadoutByName(SET_TO_LOAD)
			--ClassTalentTalentsTabMixin:LoadConfigByName(SET_TO_LOAD) -- yeah well this does not work, thx blizz
			local newConfigID = ConfigNameToIDMAP[SET_TO_LOAD]
			local result = ClassTalentFrame.TalentsTab:LoadConfigInternal(newConfigID, true, false)
			isUpdatingLoadout = true
			loadingSet = SET_TO_LOAD
		else
			print("TLOR: Cannot change talents now")
		end
	end)
	TalentLoadSetButton:SetText("Load '"..SET_TO_LOAD.."'")

	TalentLoadoutReminderFrame:Show()
end


function addon:PLAYER_ENTERING_WORLD(isLogIn, isReload)
	if isLogIn then
		return
	elseif isReload then
		return
	end

	self:checkAndShow()
end

function addon:loadDefaultDB() 
	TalentLoadoutReminderDB = TalentLoadoutReminderDB or CopyTable(self.defaultDB)
end

function addon:PLAYER_LOGIN()
	SLASH_TALENTLOADOUTREMINDER1 = "/talentloadoutreminder"
	SLASH_TALENTLOADOUTREMINDER2 = "/tlor"
	SlashCmdList["TALENTLOADOUTREMINDER"] = function(input)

		input = SecureCmdOptionParse(input)
		if not input then return end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if command == "config" then
			InterfaceOptionsFrame_OpenToCategory(addon.optionsPanel)
		end

		if command == "check" then 
			self:checkAndShow()
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


function addon:initLoadoutReminderFrame()

	TalentLoadoutReminderFrame.title = TalentLoadoutReminderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	TalentLoadoutReminderFrame.title:SetPoint("CENTER", TalentLoadoutReminderFrameTitleBG, "CENTER", 5, 0)
	TalentLoadoutReminderFrame.title:SetText("Talent Loadout Reminder")

  
	TalentLoadoutReminderFrame.ContentFrame = CreateFrame("Frame", nil, TalentLoadoutReminderFrame)
	TalentLoadoutReminderFrame.ContentFrame:SetSize(300, 150)
	TalentLoadoutReminderFrame.ContentFrame:SetPoint("TOPLEFT", TalentLoadoutReminderFrameDialogBG, "TOPLEFT", -3, 4)

	TalentLoadoutReminderFrame.ContentFrame.text = TalentLoadoutReminderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	TalentLoadoutReminderFrame.ContentFrame.text:SetPoint("TOP", TalentLoadoutReminderFrameDialogBG, "TOP", 5, -10)

	makeFrameMoveable()

	local bLoad = CreateFrame("Button", "TalentLoadSetButton", TalentLoadoutReminderFrame, "SecureActionButtonTemplate,UIPanelButtonTemplate")
	--bLoad:RegisterForClicks("AnyUp", "AnyDown")
	bLoad:SetSize(200 ,30)
	bLoad:SetPoint("CENTER", TalentLoadoutReminderFrame, "CENTER", 0, -15)	
	bLoad:SetText("Load Talentset")
end

function addon:updateOptionDropdowns()
	addon:initializeDropdownValues(DropdownDUNGEON, "DUNGEON")
	addon:initializeDropdownValues(DropdownRAID, "RAID")
	addon:initializeDropdownValues(DropdownARENA, "ARENA")
	addon:initializeDropdownValues(DropdownBG, "BG")
	addon:initializeDropdownValues(DropdownOPENWORLD, "OPENWORLD") 
end

function addon:initOptions()
	self.optionsPanel = CreateFrame("Frame")
	self.optionsPanel:HookScript("OnShow", function(self)
		addon:updateOptionDropdowns()
		end)
	self.optionsPanel.name = "TalentLoadoutReminder"
	local title = self.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("Talent LoadoutReminder")

	self:initDropdownMenu("DUNGEON", "Dungeon", -115, -50)
	self:initDropdownMenu("RAID", "Raid", 115, -50)

	self:initDropdownMenu("ARENA", "Arena", -115, -100)
	self:initDropdownMenu("BG", "Battlegrounds", 115, -100)

	self:initDropdownMenu("OPENWORLD", "Open World", -115, -150)

	InterfaceOptions_AddCategory(self.optionsPanel)
end

function addon:initializeDropdownValues(dropDown, linkedSetID)
	UIDropDownMenu_Initialize(dropDown, function(self) 
		-- loop through possible sets and put them as option
		local setList = addon:getTalentSets()
		for k, v in pairs(setList) do
			setName = v -- TODO: check if k or v is needed
			local info = UIDropDownMenu_CreateInfo()
			info.func = function(self, arg1, arg2, checked) 
				--print("clicked: " .. linkedSetID .. " -> " .. tostring(arg1))
				TalentLoadoutReminderDB[linkedSetID] = arg1
				UIDropDownMenu_SetText(dropDown, arg1)
				-- a new set was chosen for a new environment
				-- check if it is not already loaded anyway, then close frame if open
				if not addon:isSetLoaded(arg1) then
					addon:checkAndShow()
				else
					TalentLoadoutReminderFrame:Hide()
				end
			end

			info.text = setName
			info.arg1 = info.text
			UIDropDownMenu_AddButton(info)
		end
	end)
	local linkedSetName = TalentLoadoutReminderDB[linkedSetID]
	local linkedSetConfigID = ConfigNameToIDMAP[linkedSetName]
	if linkedSetName ~= nil and linkedSetConfigID ~= nil then
		UIDropDownMenu_SetText(dropDown, linkedSetName)
	else
		if TalentLoadoutReminderDB["CURRENT_SET"] == linkedSetName then
			TalentLoadoutReminderDB["CURRENT_SET"] = nil -- fallback set?
		end
		TalentLoadoutReminderDB[linkedSetID] = nil
		UIDropDownMenu_SetText(dropDown, "Choose a talent set")
	end
end

function addon:initDropdownMenu(linkedSetID, label, offsetX, offsetY)
	local dropDown = CreateFrame("Frame", "Dropdown" .. linkedSetID, self.optionsPanel, "UIDropDownMenuTemplate")
	dropDown:SetPoint("TOP", self.optionsPanel, offsetX, offsetY)
	UIDropDownMenu_SetWidth(dropDown, 200) -- Use in place of dropDown:SetWidth
	
	addon:initializeDropdownValues(dropDown, linkedSetID)

	-- local linkedSetName = TalentLoadoutReminderDB[linkedSetID]
	-- local linkedSetConfigID = ConfigNameToIDMAP[linkedSetName]
	-- if linkedSetName ~= nil and linkedSetConfigID ~= nil then
	-- 	UIDropDownMenu_SetText(dropDown, linkedSetName)
	-- else
	-- 	UIDropDownMenu_SetText(dropDown, "Choose a talent set")
	-- end

	local dd_title = dropDown:CreateFontString('dd_title', 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOP", 0, 10)
	dd_title:SetText(label)
end

function makeFrameMoveable()
	TalentLoadoutReminderFrame:SetMovable(true)
	TalentLoadoutReminderFrame:SetScript("OnMouseDown", function(self, button)
		self:StartMoving()
		end)
		TalentLoadoutReminderFrame:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing()
		end)
end