---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.TALENTS : Frame
LoadoutReminder.TALENTS = CreateFrame("Frame")
LoadoutReminder.TALENTS:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.TALENTS:RegisterEvent("TRAIT_CONFIG_UPDATED")
LoadoutReminder.TALENTS:RegisterEvent("CONFIG_COMMIT_FAILED")
LoadoutReminder.TALENTS:RegisterEvent("TRAIT_TREE_CHANGED")

LoadoutReminder.TALENTS.TALENT_MANAGER = {}

function LoadoutReminder.TALENTS:InitTalentManagement()
	-- check if optdep is loaded and set to it, otherwise use base implementation
	local DEPENDENCY_MAP = {
		[LoadoutReminder.CONST.TALENT_MANAGEMENT_ADDONS.TALENTLOADOUTMANAGER] = LoadoutReminder.TALENTS
			.TALENT_LOADOUT_MANAGER,
	}

	for name, plugin in pairs(DEPENDENCY_MAP) do
		if select(2, C_AddOns.IsAddOnLoaded(name)) then
			LoadoutReminder.TALENTS.TALENT_MANAGER = plugin
			LoadoutReminder.TALENTS.TALENT_MANAGER:InitHooks()
			return
		end
	end

	LoadoutReminder.TALENTS.TALENT_MANAGER = LoadoutReminder.TALENTS.BLIZZARD
	LoadoutReminder.TALENTS.TALENT_MANAGER:InitHooks()
end

--- TALENT LOADOUT MANAGER: https://github.com/NumyAddon/TalentLoadoutManager
LoadoutReminder.TALENTS.TALENT_LOADOUT_MANAGER = {}

function LoadoutReminder.TALENTS.TALENT_LOADOUT_MANAGER:InitHooks()
	-- When List changes (Create, Import, Delete)
	TalentLoadoutManagerAPI:RegisterCallback(TalentLoadoutManagerAPI.Event.LoadoutListUpdated, function()
		if LoadoutReminder.OPTIONS.optionsPanel then
			-- handle calls before options are initialized
			LoadoutReminder.OPTIONS:ReloadDropdowns()
			LoadoutReminder.CHECK:CheckSituations()
		end
	end, LoadoutReminder.TALENTS)

	-- should be triggered after a rename?
	TalentLoadoutManagerAPI:RegisterCallback(TalentLoadoutManagerAPI.Event.LoadoutUpdated, function()
		if LoadoutReminder.OPTIONS.optionsPanel then
			-- handle calls before options are initialized
			LoadoutReminder.OPTIONS:ReloadDropdowns()
			LoadoutReminder.CHECK:CheckSituations()
		end
	end, LoadoutReminder.TALENTS)

	-- -- find usages and rename set on rename
	-- if TalentLoadoutManagerAPI.GlobalAPI.RenameLoadout then
	-- 	hooksecurefunc(TalentLoadoutManagerAPI.GlobalAPI, 'RenameLoadout', function (self, id, newName)
	-- 		-- get new sets and compare to old sets and if any name from the old set is not in the new set then it was renamed
	-- 		local oldLoadout = TalentLoadoutManagerAPI.GlobalAPI:GetLoadoutInfoByID(id)
	-- 		LoadoutReminder.UTIL:FindAndReplaceSetInDB(oldLoadout.name, newName, LoadoutReminderDBV2.TALENTS, true)
	-- 	end)
	-- end

	-- onDelete: remove from db
	if TalentLoadoutManagerAPI.GlobalAPI.DeleteLoadout then
		hooksecurefunc(TalentLoadoutManagerAPI.GlobalAPI, 'DeleteLoadout', function()
			-- get new sets and compare to old sets and if any name from the old set is not in the new set then it was renamed
			print("delete hook")
			-- TODO: check saved sets for this spec id and then set to nil if not able to find it in current talent list
			-- local talentSets =
			-- some loop
			-- old approach: LoadoutReminder.UTIL:FindAndReplaceSetInDB(loadoutToDelete.name, nil, LoadoutReminderDBV2.TALENTS, true)
		end)
	end
end

---@return (string | number)[] loadoutIDs
function LoadoutReminder.TALENTS.TALENT_LOADOUT_MANAGER:GetTalentSets()
	---@type TalentLoadoutManagerAPI_LoadoutInfo[]
	local loadouts = TalentLoadoutManagerAPI.GlobalAPI:GetLoadouts()
	local loadoutsByName = LoadoutReminder.GUTIL:Map(loadouts, function(loadoutInfo)
		return loadoutInfo.id
	end)
	return loadoutsByName
end

---@return string | number | nil loadoutID
function LoadoutReminder.TALENTS.TALENT_LOADOUT_MANAGER:GetCurrentSet()
	---@type TalentLoadoutManagerAPI_LoadoutInfo
	local loadout = TalentLoadoutManagerAPI.CharacterAPI:GetActiveLoadoutInfo()
	return (loadout and loadout.id) or nil
end

function LoadoutReminder.TALENTS.TALENT_LOADOUT_MANAGER:GetMacroTextBySet(assignedSetID)
	-- Starter Build will be handled by TLM
	local setText = assignedSetID
	if type(setText) == 'string' then
		setText = "'" .. setText .. "'"
	end
	local macroText = "/run TalentLoadoutManagerAPI.CharacterAPI:LoadLoadout(" .. setText .. ", true)"
	return macroText
end

---@param loadoutID number TLM LoadoutID or Blizzard ConfigID
---@return string | nil configName
function LoadoutReminder.TALENTS.TALENT_LOADOUT_MANAGER:GetTalentSetNameByID(loadoutID)
	local loadoutInfo = TalentLoadoutManagerAPI.GlobalAPI:GetLoadoutInfoByID(loadoutID)
	return (loadoutInfo and loadoutInfo.name) or nil
end

-- Base Implementation
LoadoutReminder.TALENTS.BLIZZARD = {}

function LoadoutReminder.TALENTS.BLIZZARD:InitHooks()
	-- TODO: refresh dropdowns on delete and create and on import
	-- TODO: find and adapt loadout when renamed
end

---@return number[] configIDs
function LoadoutReminder.TALENTS.BLIZZARD:GetTalentSets()
	local specID = PlayerUtil.GetCurrentSpecID()

	local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)

	return configIDs
end

--- find out what set is currently activated
---@return number | nil configID
function LoadoutReminder.TALENTS.BLIZZARD:GetCurrentSet()
	if C_ClassTalents.GetStarterBuildActive() then
		return Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID
	end

	-- from wowpedia
	local function GetSelectedLoadoutConfigID()
		local lastSelected = PlayerUtil.GetCurrentSpecID() and
			C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID())
		local selectionID = ClassTalentFrame and ClassTalentFrame.TalentsTab and
			ClassTalentFrame.TalentsTab.LoadoutDropDown and ClassTalentFrame.TalentsTab.LoadoutDropDown.GetSelectionID and
			ClassTalentFrame.TalentsTab.LoadoutDropDown:GetSelectionID()

		-- the priority in authoritativeness is [default UI's dropdown] > [API] > ['ActiveConfigID'] > nil
		return selectionID or lastSelected or C_ClassTalents.GetActiveConfigID() or
			nil -- nil happens when you don't have any spec selected, e.g. on a freshly created character
	end

	local configID = GetSelectedLoadoutConfigID()

	return configID
end

---@return string macroText
function LoadoutReminder.TALENTS.BLIZZARD:GetMacroTextBySet(assignedConfigID)
	if assignedConfigID == Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID then
		-- care for the snowflake..
		return "/run C_ClassTalents.SetStarterBuildActive(true)"
	else
		local configInfo = C_Traits.GetConfigInfo(assignedConfigID)
		return "/lon " .. configInfo.name
	end
end

---@param configID number
---@return string | nil configName
function LoadoutReminder.TALENTS.BLIZZARD:GetTalentSetNameByID(configID)
	if configID == Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID then
		return 'Starter Build'
	end
	local configInfo = C_Traits.GetConfigInfo(configID)
	return (configInfo and configInfo.name) or nil
end

-- Wrappers
---@return string macroText
function LoadoutReminder.TALENTS:GetMacroTextBySet(assignedSet)
	return LoadoutReminder.TALENTS.TALENT_MANAGER:GetMacroTextBySet(assignedSet)
end

---@return string[]
function LoadoutReminder.TALENTS:GetTalentSets()
	return LoadoutReminder.TALENTS.TALENT_MANAGER:GetTalentSets()
end

--- find out what set is currently activated
function LoadoutReminder.TALENTS:GetCurrentSet()
	return LoadoutReminder.TALENTS.TALENT_MANAGER:GetCurrentSet()
end

function LoadoutReminder.TALENTS:GetTalentSetNameByID(talentSetID)
	return LoadoutReminder.TALENTS.TALENT_MANAGER:GetTalentSetNameByID(talentSetID)
end

-- EVENTS

function LoadoutReminder.TALENTS:TRAIT_CONFIG_UPDATED()
	LoadoutReminder.CHECK:CheckSituations()
	-- make another check slightly delayed
	C_Timer.After(1, function()
		LoadoutReminder.CHECK:CheckSituations()
	end)
end

function LoadoutReminder.TALENTS:CONFIG_COMMIT_FAILED()
	LoadoutReminder.CHECK:CheckSituations()
end

function LoadoutReminder.TALENTS:TRAIT_TREE_CHANGED()
	LoadoutReminder.CHECK:CheckSituations()
end

-- Base
function LoadoutReminder.TALENTS:CurrentSetRecognizable()
	return LoadoutReminder.TALENTS:GetCurrentSet() ~= nil
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.TALENTS:CheckInstanceTalentSet()
	local currentSetID = LoadoutReminder.TALENTS:GetCurrentSet()
	local assignedSetID = LoadoutReminder.DB_old.TALENTS:GetInstanceSet()

	if currentSetID and assignedSetID then
		local macroText = LoadoutReminder.TALENTS:GetMacroTextBySet(assignedSetID)
		local buttonText = 'Switch Talents to: '
		local currentSetName = LoadoutReminder.TALENTS:GetTalentSetNameByID(currentSetID)
		local assignedSetName = LoadoutReminder.TALENTS:GetTalentSetNameByID(assignedSetID)
		if currentSetName and assignedSetName then
			return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, 'Detected Situation: ',
				macroText, buttonText, "Talent Set", currentSetName, assignedSetName)
		end
	end
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.TALENTS:CheckBossTalentSet(raid, boss)
	local bossSet = LoadoutReminder.DB_old.TALENTS:GetRaidSet(raid, boss)

	if bossSet == nil then
		return nil
	end

	local currentSet = LoadoutReminder.TALENTS:GetCurrentSet()

	if currentSet then
		local currentSetName = LoadoutReminder.TALENTS:GetTalentSetNameByID(currentSet)
		local bossSetName = LoadoutReminder.TALENTS:GetTalentSetNameByID(bossSet)
		local macroText = LoadoutReminder.TALENTS:GetMacroTextBySet(bossSet)
		local reminderInfo = LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, 'Detected Boss: ',
			macroText, 'Switch Talents to: ', 'Talent Set', currentSetName, bossSetName)
		return reminderInfo
	end
end
