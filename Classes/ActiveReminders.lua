_, LoadoutReminder = ...


---@class LoadoutReminder.ActiveReminders
LoadoutReminder.ActiveReminders = LoadoutReminder.Object:extend()

---@param talents boolean
---@param addons boolean
---@param equip boolean
---@param spec boolean
function LoadoutReminder.ActiveReminders:new(talents, addons, equip, spec)
    self.talents = talents
    self.addons = addons
    self.equip = equip
    self.spec = spec
end

function LoadoutReminder.ActiveReminders:GetCount()
    local count = 0
    if self.talents then
        count = count + 1
    end
    if self.addons then
        count = count + 1
    end
    if self.equip then
        count = count + 1
    end
    if self.spec then
        count = count + 1
    end
    return count
end

--- STATIC
function LoadoutReminder.ActiveReminders:GetCombinedActiveRemindersCount(activeRemindersList)
    local combinedCount = 0
    local talentsActive = LoadoutReminder.GUTIL:Count(activeRemindersList, function (ar)
        return ar and ar.talents
    end)
    local addonsActive = LoadoutReminder.GUTIL:Count(activeRemindersList, function (ar)
        return ar and ar.addons
    end)
    local equipActive = LoadoutReminder.GUTIL:Count(activeRemindersList, function (ar)
        return ar and ar.equip
    end)
    local specActive = LoadoutReminder.GUTIL:Count(activeRemindersList, function (ar)
        return ar and ar.spec
    end)

    if talentsActive > 0 then
        combinedCount = combinedCount + 1
    end
    if addonsActive > 0 then
        combinedCount = combinedCount + 1
    end
    if equipActive > 0 then
        combinedCount = combinedCount + 1
    end
    if specActive > 0 then
        combinedCount = combinedCount + 1
    end
    return combinedCount
end