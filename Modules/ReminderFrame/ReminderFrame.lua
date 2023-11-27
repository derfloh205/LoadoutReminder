_, LoadoutReminder = ...

LoadoutReminder.REMINDER_FRAME = {}

---@param reminderInfo LoadoutReminder.ReminderInfo | nil
---@param situationText string
function LoadoutReminder.REMINDER_FRAME:UpdateDisplay(reminderType, reminderInfo, situationText, isBossCheck)
    local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
    local displayFrame = reminderFrame.content.displayFrames[reminderType]

    if not reminderInfo or reminderInfo:IsAssignedSet() then
        if not isBossCheck then
            displayFrame:collapse()
            displayFrame:Hide()
        end
        return
    else
        displayFrame:decollapse()
        displayFrame:Show()
    end

    if reminderInfo.currentSet ~= nil then
        displayFrame.info:SetText("Current ".. reminderInfo.infoText ..": \"" .. reminderInfo.currentSet .. "\"")
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
	loadSetButton:SetText(reminderInfo.buttonText .. "'" .. reminderInfo.assignedSet .. "'", nil, true)
end
