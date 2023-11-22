_, TalentLoadoutReminder = ...

TalentLoadoutReminder.REMINDER_FRAME = {}

function TalentLoadoutReminder.REMINDER_FRAME:UpdateLoadButtonMacro(SET_TO_LOAD)
    local reminderFrame = TalentLoadoutReminder.GGUI:GetFrame(TalentLoadoutReminder.MAIN.FRAMES, TalentLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
    local macroText = ""
    if SET_TO_LOAD == TalentLoadoutReminder.CONST.STARTER_BUILD then
        -- care for the snowflake..
        macroText = "/run C_ClassTalents.SetStarterBuildActive(true)"
    else
        macroText = "/lon " .. SET_TO_LOAD
    end

    ---@type GGUI.Button
	local loadSetButton = reminderFrame.content.loadButton
	loadSetButton:SetMacroText(macroText)
	loadSetButton:SetText("Change Talents to '"..SET_TO_LOAD.."'", nil, true)
end
