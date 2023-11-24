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

-- Wrapper
function LoadoutReminder.ADDONS:GetAddonSets()
	return LoadoutReminder.ADDONS.LIST_ADDON:GetAddonSets()
end

function LoadoutReminder.ADDONS.BETTER_ADDON_LIST:GetAddonSets()
    if BetterAddonListDB then
        return BetterAddonListDB.sets
    end
    return {}
end

function LoadoutReminder.ADDONS.ADDON_CONTROL_PANEL:GetAddonSets()
    -- TODO: Implement
    return {}
end