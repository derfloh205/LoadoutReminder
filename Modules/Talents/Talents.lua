_, LoadoutReminder = ...

LoadoutReminder.TALENTS = CreateFrame("Frame")
LoadoutReminder.TALENTS:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.TALENTS:RegisterEvent("TRAIT_CONFIG_UPDATED")
LoadoutReminder.TALENTS:RegisterEvent("CONFIG_COMMIT_FAILED")
LoadoutReminder.TALENTS:RegisterEvent("TRAIT_TREE_CHANGED")

function LoadoutReminder.TALENTS:CurrentSetRecognizable()
	return LoadoutReminder.TALENTS:GetCurrentSet() ~= nil
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
			local configName = configInfo.name

			-- only return if it can be found in the current list of available sets
			local availableSets = LoadoutReminder.TALENTS:GetTalentSets()

			local setExists = LoadoutReminder.GUTIL:Find(availableSets, function (set)
				return set.name == configName
			end)
			if setExists then
				return configName
			else
				return nil
			end
		end
		-- otherwise wtf?
		return nil
	else
		return nil -- no set selected yet?
	end
end

function LoadoutReminder.TALENTS:TRAIT_CONFIG_UPDATED()
	LoadoutReminder.MAIN.CheckSituations()
	-- make another check slightly delayed
	C_Timer.After(1, function ()
		LoadoutReminder.MAIN.CheckSituations()
	end)
end

function LoadoutReminder.TALENTS:CONFIG_COMMIT_FAILED()
	LoadoutReminder.MAIN.CheckSituations()
end

function LoadoutReminder.TALENTS:TRAIT_TREE_CHANGED() 
	LoadoutReminder.MAIN.CheckSituations()
end

function LoadoutReminder.TALENTS:GetMacroTextBySet(assignedSet)
	if assignedSet == LoadoutReminder.CONST.STARTER_BUILD then
		-- care for the snowflake..
		return "/run C_ClassTalents.SetStarterBuildActive(true)"
	else
		return "/lon " .. assignedSet
	end
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.TALENTS:CheckInstanceTalentSet()

	if LoadoutReminder.TALENTS:HasRaidTalentsPerBoss() then
		return
	end

	local specID = GetSpecialization()
	local INSTANCE_SETS = LoadoutReminderDB.TALENTS.GENERAL[specID]
	local CURRENT_SET = LoadoutReminder.TALENTS:GetCurrentSet()

	local currentSet, assignedSet = LoadoutReminder.UTIL:CheckCurrentSetAgainstInstanceSetList(CURRENT_SET, INSTANCE_SETS)

	if currentSet and assignedSet then
		local macroText = LoadoutReminder.TALENTS:GetMacroTextBySet(assignedSet)
		local buttonText = 'Switch Talents to: '
		return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, 'Detected Situation: ', macroText, buttonText, "Talent Set", currentSet, assignedSet)
	end
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.TALENTS:CheckBossTalentSet(boss)
	local specID = GetSpecialization()
	local bossSet = LoadoutReminderDB.TALENTS.BOSS[specID][boss]
	
	if bossSet == nil then
		return nil
	end
	
	local currentSet = LoadoutReminder.TALENTS:GetCurrentSet()
	
	local macroText = LoadoutReminder.TALENTS:GetMacroTextBySet(bossSet)
	local reminderInfo = LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, 'Detected Boss: ', macroText, 'Switch Talents to: ', 'Talent Set', currentSet, bossSet)
	return reminderInfo
end

function LoadoutReminder.TALENTS:HasRaidTalentsPerBoss()
	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	local raid = LoadoutReminder.CONST.INSTANCE_IDS[instanceID]

	if not raid then
		return false
	end

	return LoadoutReminderOptions.TALENTS.RAIDS_PER_BOSS[raid]
end