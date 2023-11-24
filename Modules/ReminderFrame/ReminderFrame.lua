_, LoadoutReminder = ...

LoadoutReminder.REMINDER_FRAME = {}

function LoadoutReminder.REMINDER_FRAME:UpdateLoadButtonMacro(SET_TO_LOAD)
    local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
    local macroText = ""
    if SET_TO_LOAD == LoadoutReminder.CONST.STARTER_BUILD then
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
