_, LoadoutReminder = ...
LoadoutReminder.REMINDER_FRAME.FRAMES = {}

function LoadoutReminder.REMINDER_FRAME.FRAMES:Init()
    local sizeX = 320
    local sizeY_1 = 120
    local sizeY_2 = 220
    local sizeY_3 = 320
    local offsetX = -10
    local offsetY = 30

    --- @type GGUI.Frame | GGUI.Widget
    local reminderFrame = LoadoutReminder.GGUI.Frame({
        parent=UIParent, 
        anchorParent=UIParent,
        anchorA="CENTER",anchorB="CENTER",
        sizeX=sizeX,sizeY=sizeY_1,
        offsetX=offsetX,offsetY=offsetY,
        frameID=LoadoutReminder.CONST.FRAMES.REMINDER_FRAME, 
        title="Loadout Reminder",
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=LoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS, 
        frameConfigTable=LoadoutReminderGGUIConfig,
        frameTable=LoadoutReminder.MAIN.FRAMES,
    })

    local function createContent(frame)

        local innerFramesBaseOffsetY = -60
        frame.content.bossInfo = LoadoutReminder.GGUI.Text({
            parent=frame.content, anchorParent=frame.content, offsetX=0, offsetY=-40,
            anchorA="TOP", anchorB="TOP",
            text="Boss Text",
        })
        frame.content.talentFrame = CreateFrame('Frame', nil, frame.content)
        local talentFrame = frame.content.talentFrame
        talentFrame:SetSize(320, 60)
        talentFrame:SetPoint("TOP", frame.content, "TOP", 0, innerFramesBaseOffsetY)

        --- @type GGUI.Text
        talentFrame.info = LoadoutReminder.GGUI.Text({
            parent=talentFrame, anchorParent=talentFrame, offsetX=0, offsetY=0,
            anchorA="TOP", anchorB="TOP",
            text="",
        })

        talentFrame.loadButton = LoadoutReminder.GGUI.Button({
            parent=talentFrame, anchorParent=talentFrame, anchorA="BOTTOM", anchorB="BOTTOM",
            label="Load Set", adjustWidth=true, macro=true, offsetY=20
        })
        
        frame:Hide()
    end

    createContent(reminderFrame)
end