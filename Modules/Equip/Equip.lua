_, LoadoutReminder = ...

LoadoutReminder.EQUIP = {}

function LoadoutReminder.EQUIP:InitEquipDB()
	local playerSpecID = GetSpecialization()
	LoadoutReminderDB.EQUIP.GENERAL[playerSpecID] = LoadoutReminderDB.EQUIP.GENERAL[playerSpecID] or {}
	LoadoutReminderDB.EQUIP.BOSS[playerSpecID] = LoadoutReminderDB.EQUIP.BOSS[playerSpecID] or {}
end

---@return string | nil currentEquipSet, string | nil assignedEquipSet or nil if assigned set is already set
function LoadoutReminder.EQUIP:CheckGeneralEquipSet()
   -- check currentSet against general set list (dont forget the speck id)
   local specID = GetSpecialization()
   local GENERAL_SETS = LoadoutReminderDB.EQUIP.GENERAL[specID]
   local CURRENT_SET = LoadoutReminder.EQUIP:GetCurrentSet()

   return LoadoutReminder.UTIL:CheckCurrentSetAgainstGeneralSetList(CURRENT_SET, GENERAL_SETS)
end

function LoadoutReminder.EQUIP:GetCurrentSet()
    -- TODO: Implement
    return nil
end