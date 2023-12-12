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
        displayFrame.info:SetText("Current ".. tostring(reminderInfo.infoText) ..": \"" .. tostring(reminderInfo.currentSet) .. "\"")
    else
        displayFrame.info:SetText("Current Set not recognized")
    end

    if situationText then
        local difficulty = LoadoutReminder.UTIL:GetInstanceDifficulty() or "" -- to prevent preload errors
        local instanceType = LoadoutReminder.UTIL:GetCurrentInstanceType()
        local difficultyText
        if not LoadoutReminder.UTIL:InstanceTypeSupportsDifficulty(instanceType) then
            difficultyText = ""
        else
            difficultyText = " (" .. tostring(LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES[difficulty]) .. ")"
        end
        reminderFrame.content.situationInfo:SetText(tostring(reminderInfo.situationInfo) .. situationText .. difficultyText)
    end

    -- update button

    ---@type GGUI.Button
	local loadSetButton = displayFrame.loadButton
	loadSetButton:SetMacroText(reminderInfo.macroText)
	loadSetButton:SetText(reminderInfo.buttonText .. "'" .. tostring(reminderInfo.assignedSet) .. "'", nil, true)
end
