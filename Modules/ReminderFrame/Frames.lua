_, LoadoutReminder = ...
LoadoutReminder.REMINDER_FRAME.FRAMES = {}

function LoadoutReminder.REMINDER_FRAME.FRAMES:Init()
    local sizeX = 320
    local sizeY_1 = 140
    local sizeY_2 = 200
    local sizeY_3 = 260
    local sizeY_4 = 320
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
        initialStatusID='ONE',
    })

    reminderFrame:SetStatusList({
        {
            statusID='ONE',
            sizeY=sizeY_1,
        },
        {
            statusID='TWO',
            sizeY=sizeY_2,
        },
        {
            statusID='THREE',
            sizeY=sizeY_3,
        },
        {
            statusID='FOUR',
            sizeY=sizeY_4,
        },
    })

    local function createContent(reminderFrame)

        local innerFramesBaseOffsetY = -80
        reminderFrame.content.situationInfo = LoadoutReminder.GGUI.Text({
            parent=reminderFrame.content, anchorParent=reminderFrame.content, offsetX=0, offsetY=-40,
            anchorA="TOP", anchorB="TOP",
            text="Situation Text",
        })

        local function createDisplayFrame(parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
            local displayFrameHeight = 60
            local frame = CreateFrame('Frame', nil, parent)
            frame:SetSize(320, displayFrameHeight)
            frame:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)

            --- @type GGUI.Text
            frame.info = LoadoutReminder.GGUI.Text({
                parent=frame, anchorParent=frame, offsetX=0, offsetY=0,
                anchorA="TOP", anchorB="TOP",
                text="",
            })

            --- @type GGUI.Button
            frame.loadButton = LoadoutReminder.GGUI.Button({
                parent=frame, anchorParent=frame, anchorA="BOTTOM", anchorB="BOTTOM",
                label="Load Set", adjustWidth=true, macro=true, offsetY=20
            })

            frame.collapse = function ()
                frame:SetSize(320, 1)
            end
            frame.decollapse = function ()
                frame:SetSize(320, displayFrameHeight)
            end

            frame.collapse() -- start collapsed

            return frame
        end
        reminderFrame.content.displayFrames = {}
        reminderFrame.content.displayFrames[LoadoutReminder.CONST.REMINDER_TYPES.TALENTS] = 
        createDisplayFrame(reminderFrame.content, reminderFrame.content, "TOP", "TOP", 0, innerFramesBaseOffsetY)
        reminderFrame.content.displayFrames[LoadoutReminder.CONST.REMINDER_TYPES.ADDONS] =
        createDisplayFrame(reminderFrame.content, reminderFrame.content.displayFrames[LoadoutReminder.CONST.REMINDER_TYPES.TALENTS], "TOP", "BOTTOM", 0, 0)
        reminderFrame.content.displayFrames[LoadoutReminder.CONST.REMINDER_TYPES.EQUIP] =
        createDisplayFrame(reminderFrame.content, reminderFrame.content.displayFrames[LoadoutReminder.CONST.REMINDER_TYPES.ADDONS], "TOP", "BOTTOM", 0, 0)
        reminderFrame.content.displayFrames[LoadoutReminder.CONST.REMINDER_TYPES.SPEC] =
        createDisplayFrame(reminderFrame.content, reminderFrame.content.displayFrames[LoadoutReminder.CONST.REMINDER_TYPES.EQUIP], "TOP", "BOTTOM", 0, 0)

        reminderFrame:Hide()
    end

    createContent(reminderFrame)
end