---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.EQUIP : Frame
LoadoutReminder.EQUIP = CreateFrame("Frame")
LoadoutReminder.EQUIP:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.EQUIP:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
LoadoutReminder.EQUIP:RegisterEvent("EQUIPMENT_SETS_CHANGED")

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

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.EQUIP:CheckInstanceEquipSet(instanceType, difficulty)
    local currentSetID = LoadoutReminder.EQUIP:GetCurrentSet()
    local assignedSetID = LoadoutReminder.DB.EQUIP:GetInstanceSet(instanceType, difficulty)

    -- print("equip: ")
    -- print("currentSet: " .. tostring(currentSet))
    -- print("assignedSet: " .. tostring(assignedSet))
    local currentSetName = (currentSetID and LoadoutReminder.EQUIP:GetEquipSetNameByID(currentSetID)) or
        LoadoutReminder.CONST.NO_SET_NAME
    local assignedSetName = (assignedSetID and LoadoutReminder.EQUIP:GetEquipSetNameByID(assignedSetID)) or nil

    if currentSetName and assignedSetName then
        local macroText = LoadoutReminder.EQUIP:GetMacroTextBySet(assignedSetID)
        local buttonText = 'Switch Equip to: '
        return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, 'Detected Situation: ', macroText,
            buttonText, "Equip Set", currentSetName, assignedSetName)
    end
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param difficulty LoadoutReminder.Difficulty
---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.EQUIP:CheckBossEquipSet(raid, boss, difficulty)
    local bossSet = LoadoutReminder.DB.EQUIP:GetRaidBossSet(raid, boss, difficulty)

    if bossSet == nil then
        return nil
    end

    local currentSet = LoadoutReminder.EQUIP:GetCurrentSet()
    local currentSetName = (currentSet and LoadoutReminder.EQUIP:GetEquipSetNameByID(currentSet)) or
        LoadoutReminder.CONST.NO_SET_NAME
    local bossSetName = LoadoutReminder.EQUIP:GetEquipSetNameByID(bossSet)
    if bossSetName then
        local macroText = LoadoutReminder.EQUIP:GetMacroTextBySet(bossSet)
        return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, 'Detected Boss: ', macroText,
            'Switch Equip to: ', 'Equip Set', currentSetName, bossSetName)
    end
end

---@return number | nil equipSetID
function LoadoutReminder.EQUIP:GetCurrentSet()
    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()

    for _, setID in pairs(setIDs) do
        local isEquipped = select(4, C_EquipmentSet.GetEquipmentSetInfo(setID))
        if isEquipped then
            return setID
        end
    end

    return nil
end

---@return number[] equipSetIDs
function LoadoutReminder.EQUIP:GetEquipSets()
    return C_EquipmentSet.GetEquipmentSetIDs()
end

function LoadoutReminder.EQUIP:GetEquipSetNameByID(setID)
    local setName = select(1, C_EquipmentSet.GetEquipmentSetInfo(setID))
    return setName
end

function LoadoutReminder.EQUIP:GetMacroTextBySet(assignedSetID)
    local setName = LoadoutReminder.EQUIP:GetEquipSetNameByID(assignedSetID)
    return '/equipset ' .. tostring(setName)
end

function LoadoutReminder.EQUIP:PLAYER_EQUIPMENT_CHANGED()
    LoadoutReminder.CHECK:CheckSituations()
end

function LoadoutReminder.EQUIP:EQUIPMENT_SETS_CHANGED()
    LoadoutReminder.OPTIONS.FRAMES:UpdateSetListDisplay()
    LoadoutReminder.CHECK:CheckSituations()
end
