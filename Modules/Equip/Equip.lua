_, LoadoutReminder = ...

LoadoutReminder.EQUIP = {}

function LoadoutReminder.EQUIP:InitEquipDB()
	local playerSpecID = GetSpecialization()
	LoadoutReminderDB.EQUIP.GENERAL[playerSpecID] = LoadoutReminderDB.EQUIP.GENERAL[playerSpecID] or {}
	LoadoutReminderDB.EQUIP.BOSS[playerSpecID] = LoadoutReminderDB.EQUIP.BOSS[playerSpecID] or {}
end

---@return LoadoutReminder.ReminderInfo
function LoadoutReminder.EQUIP:CheckInstanceEquipSet()
   -- check currentSet against general set list (dont forget the speck id)
   local specID = GetSpecialization()
   local GENERAL_SETS = LoadoutReminderDB.EQUIP.GENERAL[specID]
   local CURRENT_SET = LoadoutReminder.EQUIP:GetCurrentSet()

   return LoadoutReminder.UTIL:CheckCurrentSetAgainstInstanceSetList(CURRENT_SET, GENERAL_SETS)
end

function LoadoutReminder.EQUIP:GetCurrentSet()
    -- TODO: Implement
    return nil
end