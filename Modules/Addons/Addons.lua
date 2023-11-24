_, LoadoutReminder = ...

LoadoutReminder.ADDONS = {}
LoadoutReminder.ADDONS.LIST_ADDON = nil

LoadoutReminder.ADDONS.BETTER_ADDON_LIST = {}
LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL = {}

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
            return true
        end
    end

    return false
end

---@return string | nil currentAddonSet, string | nil assignedAddonSet or nil if assigned set is already set
function LoadoutReminder.ADDONS:CheckGeneralAddonSet()
    -- check currentSet against general set list
   local GENERAL_SETS = LoadoutReminderDB.ADDONS.GENERAL
   local CURRENT_SET = LoadoutReminder.ADDONS:GetCurrentSet()

   return LoadoutReminder.UTIL:CheckCurrentSetAgainstGeneralSetList(CURRENT_SET, GENERAL_SETS)
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

--- find out what set is currently activated by iterating the addonlist
function LoadoutReminder.ADDONS.BETTER_ADDON_LIST:GetCurrentSet()
	local numAddons = C_AddOns.GetNumAddOns()
	local character = UnitName("player")
	local enabledAddons = {}

	for addonIndex=1, numAddons do
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

function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetAddonSets()
    -- TODO: Implement
    return {}
end
function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetCurrentSet()
    -- TODO: Implement
    return nil
end