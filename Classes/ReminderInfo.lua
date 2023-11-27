_, LoadoutReminder = ...


---@class LoadoutReminder.ReminderInfo
LoadoutReminder.ReminderInfo = LoadoutReminder.Object:extend()

---@param reminderType LoadoutReminder.REMINDER_TYPES
---@param situationInfo string
---@param macroText string
---@param currentSet string
---@param assignedSet string
function LoadoutReminder.ReminderInfo:new(reminderType, situationInfo, macroText, currentSet, assignedSet)
    self.reminderType = reminderType
    self.situationInfo = situationInfo
    self.macroText = macroText
    self.currentSet = currentSet
    self.assignedSet = assignedSet
end

function LoadoutReminder.ReminderInfo:IsAssignedSet()
    return self.currentSet == self.assignedSet
end