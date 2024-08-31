---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.ADDONS
LoadoutReminder.ADDONS = {}
LoadoutReminder.ADDONS.LIST_ADDON = nil

LoadoutReminder.ADDONS.BETTER_ADDON_LIST = {}
LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL = {}

LoadoutReminder.ADDONS.AVAILABLE = false

---@return boolean success true if list_addon could be loaded, false if otherwise
function LoadoutReminder.ADDONS:Init()
	-- check if optdep is loaded and set to it
	local DEPENDENCY_MAP = {
		[LoadoutReminder.CONST.ADDON_LIST_ADDONS.ADDON_CONTROL_PANEL] = LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL,
		[LoadoutReminder.CONST.ADDON_LIST_ADDONS.BETTER_ADDON_LIST] = LoadoutReminder.ADDONS.BETTER_ADDON_LIST,
	}

	for name, plugin in pairs(DEPENDENCY_MAP) do
		if C_AddOns.IsAddOnLoaded(name) then
			LoadoutReminder.ADDONS.LIST_ADDON = plugin
			LoadoutReminder.ADDONS.AVAILABLE = true
			return true
		end
	end

	return false
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.ADDONS:CheckInstanceAddonSet(instanceType, difficulty)
	-- check currentSet against general set list
	local currentSet = LoadoutReminder.ADDONS:GetCurrentSet()
	local assignedSet = LoadoutReminder.DB.ADDONS:GetInstanceSet(instanceType, difficulty)

	currentSet = currentSet or LoadoutReminder.CONST.NO_SET_NAME
	local assignedId = LoadoutReminder.ADDONS.LIST_ADDON:GetSetKey(assignedSet)

	if currentSet == assignedId then
		return nil
	end

	if currentSet and assignedId then
		local macroText = LoadoutReminder.ADDONS:GetMacroTextByListAddon(assignedSet)
		local buttonText = 'Switch Addons to: '
		return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, 'Detected Situation: ',
			macroText, buttonText, "Addon Set", currentSet, assignedSet)
	end
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param difficulty LoadoutReminder.Difficulty
---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.ADDONS:CheckBossAddonSet(raid, boss, difficulty)
	local bossSet = LoadoutReminder.DB.ADDONS:GetRaidBossSet(raid, boss, difficulty)
	local assignedId = LoadoutReminder.ADDONS.LIST_ADDON:GetSetKey(bossSet)

	if bossSet == nil then
		return nil
	end

	local currentSet = LoadoutReminder.ADDONS:GetCurrentSet() or LoadoutReminder.CONST.NO_SET_NAME

	if currentSet == assignedId then
		return nil
	end

	if currentSet and assignedId then
		local macroText = LoadoutReminder.ADDONS:GetMacroTextByListAddon(bossSet)
		return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, 'Detected Boss: ', macroText,
			'Switch Addons to: ', "Addon Set", currentSet, bossSet)
	end
end

-- Wrapper
function LoadoutReminder.ADDONS:GetAddonSets()
	return LoadoutReminder.ADDONS.LIST_ADDON:GetAddonSets()
end

function LoadoutReminder.ADDONS:GetCurrentSet()
	return LoadoutReminder.ADDONS.LIST_ADDON:GetCurrentSet()
end

function LoadoutReminder.ADDONS:GetName(data, key)
	if data.name then
		return data.name
	else
		return key
	end
end

function LoadoutReminder.ADDONS:GetEnabledAddon()
	local numAddons = C_AddOns.GetNumAddOns()
	local character = UnitName("player")
	local enabledAddons = {}

	for addonIndex = 1, numAddons do
		local enabledState = C_AddOns.GetAddOnEnableState(addonIndex, character)
		if enabledState > 0 then
			local addonName = C_AddOns.GetAddOnInfo(addonIndex)
			-- skip for BAL cause it does not include itself in the set lists
			if addonName ~= 'BetterAddonList' then
				-- as map for instant check
				enabledAddons[addonName] = true
			end
		end
	end

	return enabledAddons;
end

function LoadoutReminder.ADDONS:GetMatchingAddons(addonList)
	local enabledAddons = LoadoutReminder.ADDONS:GetEnabledAddon()

	for key, addonName in pairs(addonList) do
		if key == "name" then
			return true
		end

		--print("- addon: " .. addonName)
		if enabledAddons[addonName] == nil then
			-- cannot be this set
			-- print("- Failed because of addon: " .. addonName, key)
			return false
		end
	end
	return true
end

function LoadoutReminder.ADDONS.BETTER_ADDON_LIST:GetAddonSets()
	if BetterAddonListDB then
		return BetterAddonListDB.sets
	end
	return {}
end

function LoadoutReminder.ADDONS:GetMacroTextByListAddon(assignedSet)
	return LoadoutReminder.ADDONS.LIST_ADDON:GetMacroText(assignedSet)
end

--- find out what set is currently activated by iterating the addonlist
function LoadoutReminder.ADDONS.BETTER_ADDON_LIST:GetCurrentSet()
	-- check against list of addon sets of BAL
	-- early return when matching set is found
	for set, addons in pairs(BetterAddonListDB.sets) do
		if LoadoutReminder.ADDONS:GetMatchingAddons(addons) then
			return set
		end
	end
end

function LoadoutReminder.ADDONS.BETTER_ADDON_LIST:GetSetKey(assignedSet)
	return assignedSet
end

function LoadoutReminder.ADDONS.BETTER_ADDON_LIST:GetMacroText(assignedSet)
	return "/addons load " .. assignedSet .. "\n/reload"
end

function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetAddonSets()
	if ACP_Data then
		local sets = {};
		for key, data in pairs(ACP_Data.AddonSet) do 
			local name = LoadoutReminder.ADDONS:GetName(data, key)
			sets[name] = key;
		end
		return sets;
	end
	return sets
end

function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetCurrentSet()
	for set, addons in pairs(ACP_Data.AddonSet) do
		local name = LoadoutReminder.ADDONS:GetName(addons, key)
		-- print("Checking Set : ", name);
		if LoadoutReminder.ADDONS:GetMatchingAddons(addons) then
			-- print("Found Matching Set : ", set);
			return set
		end
	end
end

function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetSetKey(assignedSet)
	for key, addons in pairs(ACP_Data.AddonSet) do
		local name = LoadoutReminder.ADDONS:GetName(addons, key)
		if name == assignedSet then
			return key
		end
	end

	return assignedSet
end

function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetMacroText(assignedSet)
	local id = LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetSetKey(assignedSet)
	return "/acp disableall\n/acp addset " .. id .. "\n/rl"
end