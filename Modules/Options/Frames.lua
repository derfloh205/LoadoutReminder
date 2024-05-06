---@diagnostic disable: assign-type-mismatch
---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

local GGUI = LoadoutReminder.GGUI
local GUTIL = LoadoutReminder.GUTIL
local f = GUTIL:GetFormatter()

---@class LoadoutReminder.OPTIONS
LoadoutReminder.OPTIONS = LoadoutReminder.OPTIONS

---@type LoadoutReminder.OPTIONS.FRAME
LoadoutReminder.OPTIONS.frame = nil

---@type boolean
LoadoutReminder.OPTIONS.initialized = false

---@class LoadoutReminder.OPTIONS.FRAMES
LoadoutReminder.OPTIONS.FRAMES = {}

function LoadoutReminder.OPTIONS.FRAMES:Init()
    local frameX = 800
    local frameY = 400
    ---@class LoadoutReminder.OPTIONS.FRAME : GGUI.Frame
    LoadoutReminder.OPTIONS.frame = GGUI.Frame {
        parent = UIParent, moveable = true, closeable = true,
        sizeX = frameX, sizeY = frameY,
        backdropOptions = LoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameConfigTable = LoadoutReminder.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameID = LoadoutReminder.CONST.FRAMES.OPTIONS,
        frameTable = LoadoutReminder.INIT.FRAMES,
        title = f.white("Loadout Reminder Configuration"),
        hide = true,
        frameStrata = "DIALOG",
    }

    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content

    content.generalList = LoadoutReminder.UTIL:SingleColumnFrameList(
        function()
            -- update display
            if content.generalList.selectedRow.selectedValue == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.INSTANCE_TYPES then
                content.instanceTypesList:Show()
                content.raidList:Hide()
                content.raidBossList:Hide()
                content.difficultyList:SetAnchorPoints { { anchorParent = content.instanceTypesList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 20 } }
                if content.instanceTypesList.selectedRow and LoadoutReminder.UTIL:InstanceTypeSupportsDifficulty(content.instanceTypesList.selectedRow.selectedValue) then
                    content.difficultyList:Show()
                else
                    content.difficultyList:Hide()
                end
            elseif content.generalList.selectedRow.selectedValue == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.RAID_BOSSES then
                content.instanceTypesList:Hide()
                content.raidList:Show()
                content.raidBossList:Show()
                content.difficultyList:Show()
                content.difficultyList:SetAnchorPoints { { anchorParent = content.raidBossList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 20 } }
            end

            self:UpdateSetListDisplay()
        end,
        content,
        { {
            anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 20, offsetY = -40
        } },
        160,
        true,
        GUTIL:Map(LoadoutReminder.CONST.GENERAL_REMINDER_TYPES_DISPLAY_NAMES, function(label, value)
            return {
                label = label,
                value = value
            }
        end), LoadoutReminder.CONST.GENERAL_SELECTION_RGBA, LoadoutReminder.CONST.GENERAL_HOVER_RGBA
    )

    content.selectionSummary = GGUI.Text {
        parent = content, anchorPoints = { { anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -192 } },
        text = "<selectionSummary>"
    }

    content.remindPerBossCheckbox = GGUI.Checkbox {
        parent = content, anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetX = 210, offsetY = -15,
        label = "Enable Boss Reminders",
        tooltip = "If this is " .. f.g("enabled") .. ", you will be reminded of boss specific loadouts for this raid " .. f.bb("on boss targeting\n")
            .. "If it is " .. f.r("disabled") .. " you will only be reminded on reload/load-ins for " .. f.white("'Any Boss'") .. " Loadouts",
        clickCallback = function(_, checked)
            LoadoutReminder.OPTIONS:SavePerBossSelection(checked)
        end
    }

    content.generalList:UpdateDisplay()

    self:InitInstanceTypesList()
    self:InitRaidList()
    self:InitRaidBossesList()
    self:InitDifficultyList()

    content.generalList:SelectRow(1)
    content.instanceTypesList:SelectRow(1)
    content.raidList:SelectRow(1)
    content.raidBossList:SelectRow(1)
    content.difficultyList:SelectRow(1)

    LoadoutReminder.OPTIONS.initialized = true

    -- Set Selector Dropdowns
    self:InitReminderTypesList()
    self:InitSetList()

    content.reminderTypesList:SelectRow(1)
    content.setList:SelectRow(1)

    self:UpdateSetListDisplay()
end

function LoadoutReminder.OPTIONS.FRAMES:InitReminderTypesList()
    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content

    content.reminderTypesList = LoadoutReminder.UTIL:SingleColumnFrameList(
        function()
            self:UpdateSetListDisplay()
        end,
        content,
        { {
            anchorParent = content.generalList.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetX = 0, offsetY = -40
        } },
        160,
        true,
        GUTIL:Map(LoadoutReminder.CONST.REMINDER_TYPES_DISPLAY_NAMES, function(label, value)
            return {
                label = label,
                value = value
            }
        end), LoadoutReminder.CONST.GENERAL_SELECTION_RGBA, LoadoutReminder.CONST.GENERAL_HOVER_RGBA
    )

    content.reminderTypesList:UpdateDisplay()
end

function LoadoutReminder.OPTIONS.FRAMES:InitSetList()
    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content

    content.setList = LoadoutReminder.UTIL:SingleColumnFrameList(
        function()
            LoadoutReminder.OPTIONS:SaveSelection()
            LoadoutReminder.CHECK:CheckSituations()
        end,
        content,
        { {
            anchorParent = content.reminderTypesList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 20
        } },
        160,
        true,
        {
            {
                label = LoadoutReminder.CONST.NO_SET_NAME,
                value = nil,
            }
        }, LoadoutReminder.CONST.SET_SELECTION_RGBA, LoadoutReminder.CONST.SET_HOVER_RGBA
    )


    content.setList:UpdateDisplay()
end

function LoadoutReminder.OPTIONS.FRAMES:InitInstanceTypesList()
    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content

    content.instanceTypesList = LoadoutReminder.UTIL:SingleColumnFrameList(
        function(row)
            local selectedInstanceType = row.selectedValue
            local diffEnabled = LoadoutReminder.UTIL:InstanceTypeSupportsDifficulty(selectedInstanceType)
            if diffEnabled then
                content.difficultyList:Show()
            else
                content.difficultyList:Hide()
            end
            self:UpdateSetListDisplay()
            self:UpdateSelectionSummary()
            self:UpdatePerBossCheckbox()
        end,
        content,
        { { anchorParent = content.generalList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 20 } },
        160,
        true,
        GUTIL:Map(LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES, function(label, value)
            if value == LoadoutReminder.CONST.INSTANCE_TYPES.RAID then return nil end -- filter out raid
            return {
                label = label,
                value = value
            }
        end), LoadoutReminder.CONST.GENERAL_SELECTION_RGBA, LoadoutReminder.CONST.GENERAL_HOVER_RGBA
    )

    content.instanceTypesList:UpdateDisplay()
end

function LoadoutReminder.OPTIONS.FRAMES:InitRaidList()
    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content

    content.raidList = LoadoutReminder.UTIL:SingleColumnFrameList(
        function(row)
            content.raidBossList:Remove()
            local raid = row.selectedValue --[[@as LoadoutReminder.Raids]]
            local bosses = LoadoutReminder.CONST.BOSS_IDS[raid]

            for boss in pairs(bosses) do
                content.raidBossList:Add(function(row, columns)
                    columns[1].text:SetText(LoadoutReminder.CONST.BOSS_NAMES[raid][boss])
                    row.selectedValue = boss
                end)
            end

            content.raidBossList:UpdateDisplay(function(rowA, rowB)
                if rowA.selectedValue == LoadoutReminder.CONST.BOSS_IDS.DEFAULT.DEFAULT then
                    return true
                else
                    return false
                end
            end)

            content.raidBossList:SelectRow(1)
            self:UpdatePerBossCheckbox()
        end,
        content,
        { { anchorParent = content.generalList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 20 } },
        160,
        true,
        GUTIL:Map(LoadoutReminder.CONST.RAID_DISPLAY_NAMES, function(label, value)
            return {
                label = label,
                value = value
            }
        end), LoadoutReminder.CONST.GENERAL_SELECTION_RGBA, LoadoutReminder.CONST.GENERAL_HOVER_RGBA
    )

    content.raidList:UpdateDisplay(function(rowA, rowB)
        if rowA.columns[1].text:GetText() == LoadoutReminder.CONST.RAID_DISPLAY_NAMES.DEFAULT then
            return true
        else
            return false
        end
    end)
end

function LoadoutReminder.OPTIONS.FRAMES:InitDifficultyList()
    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content

    content.difficultyList = LoadoutReminder.UTIL:SingleColumnFrameList(
        function(row)
            self:UpdateSelectionSummary()
            self:UpdateSetListDisplay()
            self:UpdatePerBossCheckbox()
        end,
        content,
        { { anchorParent = content.raidList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 20 } },
        160,
        true,
        GUTIL:Map(LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES, function(label, value)
            return {
                label = label,
                value = value
            }
        end), LoadoutReminder.CONST.GENERAL_SELECTION_RGBA, LoadoutReminder.CONST.GENERAL_HOVER_RGBA
    )

    content.difficultyList:UpdateDisplay(function(rowA, rowB)
        if rowA.columns[1].text:GetText() == LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES.DEFAULT then
            return true
        else
            return false
        end
    end)
end

function LoadoutReminder.OPTIONS.FRAMES:UpdateSetListDisplay()
    -- yield if options frame was not yet initialized
    if not LoadoutReminder.OPTIONS.initialized then return end

    -- print("UpdateSetListDisplay")

    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content
    local selectedReminderType = content.reminderTypesList.selectedRow
        .selectedValue --[[@as LoadoutReminder.ReminderTypes]]

    content.setList:Remove()
    local selectionData
    local selectedSetID
    local specID = LoadoutReminder.UTIL:GetPlayerSpecID()
    local selectedGeneralType = content.generalList.selectedRow and
        content.generalList.selectedRow.selectedValue --[[@as LoadoutReminder.GeneralReminderTypes]]
    local selectedInstanceType = content.instanceTypesList.selectedRow and
        content.instanceTypesList.selectedRow.selectedValue --[[@as LoadoutReminder.InstanceTypes]]
    local selectedDifficulty = content.difficultyList.selectedRow and
        content.difficultyList.selectedRow.selectedValue --[[@as LoadoutReminder.Difficulty]]
    local selectedRaid = content.raidList.selectedRow and
        content.raidList.selectedRow.selectedValue --[[@as LoadoutReminder.Raids]]
    local selectedBoss = content.raidBossList.selectedRow and
        content.raidBossList.selectedRow.selectedValue --[[@as LoadoutReminder.Raidboss]]

    if selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.SPEC then
        selectionData = LoadoutReminder.OPTIONS:GetSpecializationSelectionData()
        if selectedGeneralType == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.INSTANCE_TYPES then
            selectedSetID = LoadoutReminder.DB.SPEC:GetInstanceSet(selectedInstanceType, selectedDifficulty)
        else
            selectedSetID = LoadoutReminder.DB.SPEC:GetRaidBossSet(selectedRaid, selectedBoss, selectedDifficulty)
        end
    elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.ADDONS then
        selectionData = LoadoutReminder.OPTIONS:GetAddonsSelectionData()
        if selectedGeneralType == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.INSTANCE_TYPES then
            selectedSetID = LoadoutReminder.DB.ADDONS:GetInstanceSet(selectedInstanceType, selectedDifficulty)
        else
            selectedSetID = LoadoutReminder.DB.ADDONS:GetRaidBossSet(selectedRaid, selectedBoss, selectedDifficulty)
        end
    elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.EQUIP then
        selectionData = LoadoutReminder.OPTIONS:GetEquipSelectionData()
        if selectedGeneralType == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.INSTANCE_TYPES then
            selectedSetID = LoadoutReminder.DB.EQUIP:GetInstanceSet(selectedInstanceType, selectedDifficulty)
        else
            selectedSetID = LoadoutReminder.DB.EQUIP:GetRaidBossSet(selectedRaid, selectedBoss, selectedDifficulty)
        end
    elseif selectedReminderType == LoadoutReminder.CONST.REMINDER_TYPES.TALENTS then
        selectionData = LoadoutReminder.OPTIONS:GetTalentsSelectionData()
        if selectedGeneralType == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.INSTANCE_TYPES then
            selectedSetID = LoadoutReminder.DB.TALENTS:GetInstanceSet(selectedInstanceType, selectedDifficulty, specID)
        else
            selectedSetID = LoadoutReminder.DB.TALENTS:GetRaidBossSet(selectedRaid, selectedBoss, selectedDifficulty,
                specID)
        end
    end

    for _, data in ipairs(selectionData) do
        content.setList:Add(function(row, columns)
            row.selectedValue = data.value
            columns[1].text:SetText(data.label)
        end)
    end

    content.setList:UpdateDisplay()

    -- print("selectSetID: " .. tostring(selectedSetID))

    -- Update Selected Row
    local selectedIndex = content.setList:SelectRowWhere(function(row)
        return row.selectedValue == selectedSetID
    end, 1)

    -- print("selectedRowIndex: " .. tostring(selectedIndex))

    self:UpdateSelectionSummary()
    self:UpdatePerBossCheckbox()
end

function LoadoutReminder.OPTIONS.FRAMES:InitRaidBossesList()
    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content

    content.raidBossList = LoadoutReminder.UTIL:SingleColumnFrameList(
        function()
            self:UpdateSelectionSummary()
            self:UpdateSetListDisplay()
            self:UpdatePerBossCheckbox()
        end,
        content,
        { { anchorParent = content.raidList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 20 } },
        160,
        true,
        {
            {
                label = LoadoutReminder.CONST.BOSS_NAMES[LoadoutReminder.CONST.BOSS_IDS.DEFAULT],
                value = LoadoutReminder.CONST.BOSS_IDS.DEFAULT
            }
        }, LoadoutReminder.CONST.GENERAL_SELECTION_RGBA, LoadoutReminder.CONST.GENERAL_HOVER_RGBA
    )

    content.raidBossList:UpdateDisplay(function(rowA, rowB)
        if rowA.selectedValue == LoadoutReminder.CONST.BOSS_IDS.DEFAULT.DEFAULT then
            return true
        elseif rowB.selectedValue == LoadoutReminder.CONST.BOSS_IDS.DEFAULT.DEFAULT then
            return false
        end
    end)
end

function LoadoutReminder.OPTIONS.FRAMES:UpdateSelectionSummary()
    -- print("UpdateSelectionSummary")
    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content
    local selectedGeneralType = content.generalList.selectedRow
        .selectedValue --[[@as LoadoutReminder.GeneralReminderTypes]]

    -- print("selectedGeneralType: " .. tostring(selectedGeneralType))

    local summaryText = LoadoutReminder.CONST.GENERAL_REMINDER_TYPES_DISPLAY_NAMES[selectedGeneralType]

    if selectedGeneralType == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.INSTANCE_TYPES then
        local selectedInstanceType = content.instanceTypesList.selectedRow
            .selectedValue --[[@as LoadoutReminder.InstanceTypes]]
        summaryText = summaryText .. " -> " .. LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[selectedInstanceType]
        if LoadoutReminder.UTIL:InstanceTypeSupportsDifficulty(selectedInstanceType) then
            local selectedDifficulty = content.difficultyList.selectedRow and content.difficultyList.selectedRow
                .selectedValue or LoadoutReminder.CONST.DIFFICULTY.DEFAULT --[[@as LoadoutReminder.Difficulty]]
            summaryText = summaryText .. " -> " .. LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES[selectedDifficulty]
        end
    elseif selectedGeneralType == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.RAID_BOSSES then
        local selectedRaid = content.raidList.selectedRow.selectedValue --[[@as LoadoutReminder.Raids]]
        summaryText = summaryText .. " -> " .. LoadoutReminder.CONST.RAID_DISPLAY_NAMES[selectedRaid]

        local selectedBoss = content.raidBossList.selectedRow.selectedValue --[[@as string]]
        summaryText = summaryText .. " -> " .. LoadoutReminder.CONST.BOSS_NAMES[selectedRaid][selectedBoss]

        local selectedDifficulty = content.difficultyList.selectedRow and content.difficultyList.selectedRow
            .selectedValue or LoadoutReminder.CONST.DIFFICULTY.DEFAULT --[[@as LoadoutReminder.Difficulty]]
        summaryText = summaryText .. " -> " .. LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES[selectedDifficulty]
    end

    -- print(summaryText)


    content.selectionSummary:SetText(summaryText)
end

function LoadoutReminder.OPTIONS.FRAMES:UpdatePerBossCheckbox()
    ---@class LoadoutReminder.OPTIONS.FRAME.CONTENT : Frame
    local content = LoadoutReminder.OPTIONS.frame.content
    if content.generalList.selectedRow and content.generalList.selectedRow.selectedValue == LoadoutReminder.CONST.GENERAL_REMINDER_TYPES.RAID_BOSSES then
        if content.raidList.selectedRow and content.raidList.selectedRow.selectedValue ~= LoadoutReminder.CONST.RAIDS.DEFAULT then
            local selectedRaid = content.raidList.selectedRow and
                content.raidList.selectedRow.selectedValue --[[@as LoadoutReminder.Raids]]
            local selectedDifficulty = content.difficultyList.selectedRow.selectedValue or
                LoadoutReminder.CONST.DIFFICULTY.DEFAULT --[[@as LoadoutReminder.Difficulty]]

            local perBossOptionKey = LoadoutReminder.OPTIONS:GetPerBossOptionKey(selectedDifficulty, selectedRaid)
            local checked = LoadoutReminder.DB.OPTIONS:Get("PER_BOSS_LOADOUTS")[perBossOptionKey]
            content.remindPerBossCheckbox:SetChecked(checked)
            content.remindPerBossCheckbox:Show()
        else
            content.remindPerBossCheckbox:Hide()
        end
    else
        content.remindPerBossCheckbox:Hide()
    end
end
