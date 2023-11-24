_, LoadoutReminder = ...

LoadoutReminder.TALENTS = CreateFrame("Frame")
LoadoutReminder.TALENTS:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.TALENTS:RegisterEvent("TRAIT_CONFIG_UPDATED")
LoadoutReminder.TALENTS:RegisterEvent("CONFIG_COMMIT_FAILED")
LoadoutReminder.TALENTS:RegisterEvent("TRAIT_TREE_CHANGED")

function LoadoutReminder.TALENTS:InitTalentDB()
	local playerSpecID = GetSpecialization()
	LoadoutReminderDB.TALENTS.GENERAL[playerSpecID] = LoadoutReminderDB.TALENTS.GENERAL[playerSpecID] or {}
	LoadoutReminderDB.TALENTS.BOSS[playerSpecID] = LoadoutReminderDB.TALENTS.BOSS[playerSpecID] or {}
end

---@return TraitConfigInfo[]
function LoadoutReminder.TALENTS:GetTalentSets()
	local specID = PlayerUtil.GetCurrentSpecID()

	local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)

	local talentSets = LoadoutReminder.GUTIL:Map(configIDs, function (configID)
		return C_Traits.GetConfigInfo(configID)
	end)
	return talentSets
end

--- find out what set is currently activated
function LoadoutReminder.TALENTS:GetCurrentSet()

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

function LoadoutReminder.TALENTS:TRAIT_CONFIG_UPDATED()
	LoadoutReminder.MAIN:CheckAndShowGeneral()
	-- make another check slightly delayed
	C_Timer.After(1, function ()
		LoadoutReminder.MAIN:CheckAndShowGeneral()
	end)
end

function LoadoutReminder.TALENTS:CONFIG_COMMIT_FAILED()
	LoadoutReminder.MAIN:CheckAndShowGeneral()
end

function LoadoutReminder.TALENTS:TRAIT_TREE_CHANGED() 
	LoadoutReminder.MAIN:CheckAndShowGeneral()
end

---@return string | nil currentTalentSet, string | nil assignedTalentSet or nil if assigned set is already set
function LoadoutReminder.TALENTS:CheckGeneralTalentSet()
   -- check currentSet against general set list (dont forget the speck id)
   local specID = GetSpecialization()
   local GENERAL_SETS = LoadoutReminderDB.TALENTS.GENERAL[specID]
   local CURRENT_SET = LoadoutReminder.TALENTS:GetCurrentSet()

   return LoadoutReminder.UTIL:CheckCurrentSetAgainstGeneralSetList(CURRENT_SET, GENERAL_SETS)
end

function LoadoutReminder.TALENTS:UpdateLoadButtonMacro(SET_TO_LOAD)
    local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
    local macroText = ""
    if SET_TO_LOAD == LoadoutReminder.CONST.STARTER_BUILD then
        -- care for the snowflake..
        macroText = "/run C_ClassTalents.SetStarterBuildActive(true)"
    else
        macroText = "/lon " .. SET_TO_LOAD
    end

    ---@type GGUI.Button
	local loadSetButton = reminderFrame.content.talentFrame.loadButton
	loadSetButton:SetMacroText(macroText)
	loadSetButton:SetText("Change Talents to '"..SET_TO_LOAD.."'", nil, true)
end