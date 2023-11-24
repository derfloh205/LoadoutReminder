_, LoadoutReminder = ...

LoadoutReminder.TALENTS = CreateFrame("Frame")
LoadoutReminder.TALENTS:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.TALENTS:RegisterEvent("TRAIT_CONFIG_UPDATED")
LoadoutReminder.TALENTS:RegisterEvent("CONFIG_COMMIT_FAILED")
LoadoutReminder.TALENTS:RegisterEvent("TRAIT_TREE_CHANGED")

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