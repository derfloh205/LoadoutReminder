---@class LoadoutReminder
local LoadoutReminder = select(2, ...)
local LoadoutReminderAddonName = select(1, ...)

---@class LoadoutReminder.NEWS
LoadoutReminder.NEWS = {}

function LoadoutReminder.NEWS:Init()
    -- create news frame
    local sizeX = 420
    local sizeY = 120

    local newsFrame = LoadoutReminder.GGUI.Frame({
        parent = UIParent,
        anchorParent = UIParent,
        anchorA = "TOP",
        anchorB = "TOP",
        sizeX = sizeX,
        sizeY = sizeY,
        backdropOptions = LoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameConfigTable = LoadoutReminder.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameTable = LoadoutReminder.INIT.FRAMES,
        frameID = LoadoutReminder.CONST.FRAMES.NEWS,
        title = LoadoutReminder.GUTIL:ColorizeText(
            "LoadoutReminder " .. C_AddOns.GetAddOnMetadata(LoadoutReminderAddonName, "Version"),
            LoadoutReminder.GUTIL.COLORS.BRIGHT_BLUE),
        closeable = true,
        moveable = true,
    })

    newsFrame:Hide()

    newsFrame.content.info = LoadoutReminder.GGUI.Text({
        parent = newsFrame.content,
        anchorParent = newsFrame.content,
        offsetY = -10,
        text = "",
        justifyOptions = { type = "H", align = "LEFT" }
    })
end

function LoadoutReminder.NEWS:GET_NEWS()
    local d = LoadoutReminder.GUTIL:ColorizeText("-", LoadoutReminder.GUTIL.COLORS.GREEN)
    return string.format(
        [[
    %1$s Refactored internal db structure
    ]], d)
end

function LoadoutReminder.NEWS:GetChecksum()
    local checksum = 0
    local newsString = LoadoutReminder.NEWS:GET_NEWS()
    local checkSumBitSize = 256

    -- Iterate through each character in the string
    for i = 1, #newsString do
        checksum = (checksum + string.byte(newsString, i)) % checkSumBitSize
    end

    return checksum
end

---@return string | nil newChecksum newChecksum when news should be shown, otherwise nil
function LoadoutReminder.NEWS:IsNewsUpdate()
    local newChecksum = LoadoutReminder.NEWS:GetChecksum()
    local oldChecksum = LoadoutReminder.DB.OPTIONS:Get("NEWS_CHECKSUM")
    if newChecksum ~= oldChecksum then
        return newChecksum
    end
    return nil
end

function LoadoutReminder.NEWS:ShowNews(force)
    local infoText = LoadoutReminder.NEWS:GET_NEWS()
    local newChecksum = LoadoutReminder.NEWS:IsNewsUpdate()
    if newChecksum == nil and (not force) then
        return
    end

    LoadoutReminder.DB.OPTIONS:Save("NEWS_CHECKSUM", newChecksum)

    local newsFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.INIT.FRAMES, LoadoutReminder.CONST.FRAMES.NEWS)
    -- resize
    newsFrame.content.info:SetText(infoText)
    newsFrame:Show()
end
