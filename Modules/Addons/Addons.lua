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

---@return LoadoutReminder.ReminderInfo
function LoadoutReminder.ADDONS:CheckInstanceAddonSet()
	-- check currentSet against general set list
	local currentSet = LoadoutReminder.ADDONS:GetCurrentSet()
	local assignedSet = LoadoutReminder.DB.ADDONS:GetInstanceSet()

	currentSet = currentSet or LoadoutReminder.CONST.NO_SET_NAME

	if currentSet and assignedSet then
		local macroText = LoadoutReminder.ADDONS:GetMacroTextByListAddon(assignedSet)
		local buttonText = 'Switch Addons to: '
		return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, 'Detected Situation: ',
			macroText, buttonText, "Addon Set", currentSet, assignedSet)
	end
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.ADDONS:CheckBossAddonSet(raid, boss)
	local bossSet = LoadoutReminder.DB.ADDONS:GetRaidSet(raid, boss)

	if bossSet == nil then
		return nil
	end

	local currentSet = LoadoutReminder.ADDONS:GetCurrentSet() or LoadoutReminder.CONST.NO_SET_NAME

	if currentSet and bossSet then
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
	-- to be able to early return
	local function matchesCurrentSet(addonList)
		for _, addonName in pairs(addonList) do
			--print("- addon: " .. addonName)
			if enabledAddons[addonName] == nil then
				-- cannot be this set
				return false
			end
		end
		return true
	end

	-- check against list of addon sets of BAL
	-- early return when matching set is found
	for set, addons in pairs(BetterAddonListDB.sets) do
		if matchesCurrentSet(addons) then
			return set
		end
	end
end

function LoadoutReminder.ADDONS.BETTER_ADDON_LIST:GetMacroText(assignedSet)
	return "/addons load " .. assignedSet .. "\n/reload"
end

function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetAddonSets()
	-- TODO: Implement
	return {}
end

function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetCurrentSet()
	-- TODO: Implement
	return nil
end
