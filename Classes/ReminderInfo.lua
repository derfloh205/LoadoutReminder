---@class LoadoutReminder
local LoadoutReminder = select(2, ...)


---@class LoadoutReminder.ReminderInfo
LoadoutReminder.ReminderInfo = LoadoutReminder.Object:extend()

---@param reminderType LoadoutReminder.ReminderTypes
---@param situationInfo string
---@param macroText string
---@param currentSet string
---@param assignedSet string
function LoadoutReminder.ReminderInfo:new(reminderType, situationInfo, macroText, buttonText, infoText, currentSet,
                                          assignedSet)
    self.reminderType = reminderType
    self.situationInfo = situationInfo
    self.macroText = macroText
    self.buttonText = buttonText
    self.currentSet = currentSet
    self.assignedSet = assignedSet
    self.infoText = infoText
end

function LoadoutReminder.ReminderInfo:IsAssignedSet()
    return self.currentSet == self.assignedSet
end
