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
        frame.content.situationInfo = LoadoutReminder.GGUI.Text({
            parent=frame.content, anchorParent=frame.content, offsetX=0, offsetY=-40,
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
                frame:SetSize(320, 0)
            end
            frame.decollapse = function ()
                frame:SetSize(320, displayFrameHeight)
            end

            return frame
        end
        frame.content.displayFrames = {}
        frame.content.displayFrames[LoadoutReminder.CONST.REMINDER_TYPES.TALENTS] = 
        createDisplayFrame(frame.content, frame.content, "TOP", "TOP", 0, innerFramesBaseOffsetY)

        frame:Hide()
    end

    createContent(reminderFrame)
end