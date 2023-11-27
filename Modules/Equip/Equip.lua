_, LoadoutReminder = ...

LoadoutReminder.EQUIP = CreateFrame("Frame")
LoadoutReminder.EQUIP:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.EQUIP:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

function LoadoutReminder.EQUIP:AreEquipSetsLoaded()
    local ids = C_EquipmentSet.GetEquipmentSetIDs()

    if ids ~= nil and #ids > 0 then
        local setInfo = C_EquipmentSet.GetEquipmentSetInfo(ids[1])
        if setInfo then
            return true
        else
            return false
        end
    else
        -- player has no sets
        return true
    end
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.EQUIP:CheckInstanceEquipSet()
    if LoadoutReminder.EQUIP:HasRaidEquipPerBoss() then
		return
	end

	local INSTANCE_SETS = LoadoutReminderDB.EQUIP.GENERAL
	local CURRENT_SET = LoadoutReminder.EQUIP:GetCurrentSet()

	local currentSet, assignedSet = LoadoutReminder.UTIL:CheckCurrentSetAgainstInstanceSetList(CURRENT_SET, INSTANCE_SETS)

    -- print("equip: ")
    -- print("currentSet: " .. tostring(currentSet))
    -- print("assignedSet: " .. tostring(assignedSet))

    if currentSet == nil then
        -- suggest changing set anyway
        currentSet = '<No Set>'
    end

	if currentSet and assignedSet then
		local macroText = LoadoutReminder.EQUIP:GetMacroTextBySet(assignedSet)
		local buttonText = 'Switch Equip to: '
		return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, 'Detected Situation: ', macroText, buttonText, "Equip Set", currentSet, assignedSet)
	end
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.EQUIP:CheckBossEquipSet(boss)
	local bossSet = LoadoutReminderDB.EQUIP.BOSS[boss]

	if bossSet == nil then
		return nil
	end

	local currentSet = LoadoutReminder.EQUIP:GetCurrentSet()
	local macroText = LoadoutReminder.EQUIP:GetMacroTextBySet(bossSet)
	return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, 'Detected Boss: ', macroText, 'Switch Equip to: ', 'Equip Set', currentSet, bossSet)
end

function LoadoutReminder.EQUIP:GetCurrentSet()
    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()

    for _, setID in pairs(setIDs) do
        local setName = select(1, C_EquipmentSet.GetEquipmentSetInfo(setID))
        local isEquipped = select(4, C_EquipmentSet.GetEquipmentSetInfo(setID))
        if setName and isEquipped then
            return setName
        end
    end

    return nil
end

function LoadoutReminder.EQUIP:GetEquipSets()
    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
    local setList = {}

    for _, setID in pairs(setIDs) do
        local setName = select(1, C_EquipmentSet.GetEquipmentSetInfo(setID))
        if setName then
            table.insert(setList, setName)
        end
    end

    return setList
end

function LoadoutReminder.EQUIP:HasRaidEquipPerBoss()
    local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	local raid = LoadoutReminder.CONST.INSTANCE_IDS[instanceID]

	if not raid then
		return false
	end

	return LoadoutReminderOptions.EQUIP.RAIDS_PER_BOSS[raid]
end

function LoadoutReminder.EQUIP:GetMacroTextBySet(assignedSet)
    return '/equipset ' .. assignedSet
end

function LoadoutReminder.EQUIP:PLAYER_EQUIPMENT_CHANGED()
    LoadoutReminder.MAIN:CheckSituations()
end