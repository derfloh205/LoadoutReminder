_, LoadoutReminder = ...

LoadoutReminder.REMINDER_FRAME = {}

---@param reminderInfo LoadoutReminder.ReminderInfo
---@param situationText string
function LoadoutReminder.REMINDER_FRAME:UpdateDisplay(reminderInfo, situationText)
    local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
    local displayFrame = reminderFrame.content.displayFrames[reminderInfo.reminderType]

    if reminderInfo:IsAssignedSet() then
        print("detected assigned set, hide displayFrame")
        displayFrame:collapse()
        displayFrame:Hide()
        return
    else
        displayFrame:decollapse()
        displayFrame:Show()
    end

    if reminderInfo.currentSet ~= nil then
        displayFrame.info:SetText("Current Set: \"" .. reminderInfo.currentSet .. "\"")
    else
        displayFrame.info:SetText("Current Set not recognized")
    end

    if situationText then
        reminderFrame.content.situationInfo:SetText(reminderInfo.situationInfo .. situationText)
    end

    -- update button

    ---@type GGUI.Button
	local loadSetButton = displayFrame.loadButton
	loadSetButton:SetMacroText(reminderInfo.macroText)
	loadSetButton:SetText("Switch to '"..reminderInfo.assignedSet.."'", nil, true)
end
