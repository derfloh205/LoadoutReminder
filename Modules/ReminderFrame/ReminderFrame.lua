_, TalentLoadoutReminder = ...

TalentLoadoutReminder.REMINDER_FRAME = {}

function TalentLoadoutReminder.REMINDER_FRAME:UpdateLoadButtonMacro(SET_TO_LOAD)
    local reminderFrame = TalentLoadoutReminder.GGUI:GetFrame(TalentLoadoutReminder.MAIN.FRAMES, TalentLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
    local macroText = "/lon " .. SET_TO_LOAD

    ---@type GGUI.Button
	local loadSetButton = reminderFrame.content.loadButton
	loadSetButton:SetMacroText(macroText)
	loadSetButton:SetText("Change Talents to '"..SET_TO_LOAD.."'", nil, true)
end
