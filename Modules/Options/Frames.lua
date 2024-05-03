---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

local GGUI = LoadoutReminder.GGUI
local GUTIL = LoadoutReminder.GUTIL
local f = GUTIL:GetFormatter()

---@class LoadoutReminder.OPTIONS
LoadoutReminder.OPTIONS = LoadoutReminder.OPTIONS

---@type LoadoutReminder.OPTIONS.FRAME
LoadoutReminder.OPTIONS.frame = nil

---@class LoadoutReminder.OPTIONS.FRAMES
LoadoutReminder.OPTIONS.FRAMES = {}

function LoadoutReminder.OPTIONS.FRAMES:Init()
    ---@class LoadoutReminder.OPTIONS.FRAME : GGUI.Frame
    LoadoutReminder.OPTIONS.frame = GGUI.Frame {
        parent = UIParent, moveable = true, closeable = true,
        sizeX = 650, sizeY = 620,
        backdropOptions = LoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameConfigTable = LoadoutReminder.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameID = LoadoutReminder.CONST.FRAMES.OPTIONS,
        frameTable = LoadoutReminder.INIT.FRAMES,
        title = f.white("Loadout Reminder Options"),
        hide = true,
        frameStrata = "DIALOG",
    }

    ---@type GGUI.DropdownData
    local difficultyDropdownData = LoadoutReminder.GUTIL:Map(LoadoutReminder.CONST.DIFFICULTY, function(diff)
        return {
            label = LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES[diff],
            value = diff,
        }
    end)

    local difficultyDropdownData = LoadoutReminder.GUTIL:Sort(difficultyDropdownData, function(a, b)
        return LoadoutReminder.CONST.DIFFICULTY_SORT_ORDER[a.value] <
            LoadoutReminder.CONST.DIFFICULTY_SORT_ORDER[b.value]
    end)

    ---@type GGUI.Dropdown
    LoadoutReminder.OPTIONS.difficultyDropdown = LoadoutReminder.GGUI.Dropdown({
        parent = LoadoutReminder.OPTIONS.frame.content,
        anchorParent = LoadoutReminder.OPTIONS.frame.content,
        offsetY = -40,
        anchorA = "TOP",
        anchorB = "TOP",
        label = "Difficulty",
        initialData = difficultyDropdownData,
        initialLabel = LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES.DEFAULT,
        initialValue = LoadoutReminder.CONST.DIFFICULTY.DEFAULT,
        clickCallback = function()
            LoadoutReminder.OPTIONS.FRAMES:ReloadDropdowns()
        end
    })

    local dropdownData = {
        TALENTS = LoadoutReminder.OPTIONS:GetTalentsData(),
        EQUIP = LoadoutReminder.OPTIONS:GetEquipData(),
        SPEC = LoadoutReminder.OPTIONS:GetSpecData(),
        ADDONS = LoadoutReminder.OPTIONS:GetAddonsData()
    }

    local tabContentX = 623
    local tabContentY = 520
    local tabOffsetY = -25

    local generalTab = LoadoutReminder.GGUI.BlizzardTab({
        buttonOptions =
        {
            label = "General",
            parent = LoadoutReminder.OPTIONS.frame.content,
            anchorParent = LoadoutReminder.OPTIONS.frame.content,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            offsetX = 25,
            offsetY = -45
        },
        canBeEnabled = true,
        parent = LoadoutReminder.OPTIONS.frame.content,
        anchorParent = LoadoutReminder.OPTIONS.frame.content,
        anchorA = "CENTER",
        anchorB = "CENTER",
        offsetX = 0,
        offsetY = tabOffsetY,
        sizeX = tabContentX,
        sizeY = tabContentY,
        initialTab = true,
        top = true,
    })

    generalTab.content.background = LoadoutReminder.GGUI.Frame {
        parent = generalTab.content, anchorParent = generalTab.content, sizeX = tabContentX, sizeY = tabContentY,
        backdropOptions = LoadoutReminder.CONST.OPTIONS_TAB_CONTENT_BACKDROP,
    }

    local dbFunctions = {
        TALENTS = {
            Save = function(_, instanceType, talentSetID)
                local specID = select(1, GetSpecializationInfo(GetSpecialization()))
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                LoadoutReminder.DB.TALENTS:SaveInstanceSet(instanceType, selectedDifficulty, specID, talentSetID)
            end,
            Get = function(_, instanceType)
                local specID = select(1, GetSpecializationInfo(GetSpecialization()))
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                return LoadoutReminder.DB.TALENTS:GetInstanceSet(instanceType, selectedDifficulty, specID)
            end,
            GetInitialData = function(_, instanceType)
                local specID = select(1, GetSpecializationInfo(GetSpecialization()))
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                local talentSetID = LoadoutReminder.DB.TALENTS:GetInstanceSet(instanceType, selectedDifficulty, specID)
                local label = (talentSetID and LoadoutReminder.TALENTS:GetTalentSetNameByID(talentSetID)) or nil
                return {
                    label = label,
                    value = talentSetID
                }
            end
        },
        EQUIP = {
            Save = function(_, instanceType, equipSetID)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                LoadoutReminder.DB.EQUIP:SaveInstanceSet(instanceType, selectedDifficulty, equipSetID)
            end,
            Get = function(_, instanceType)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                return LoadoutReminder.DB.EQUIP:GetInstanceSet(instanceType, selectedDifficulty)
            end,
            GetInitialData = function(_, instanceType)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                local equipSetID = LoadoutReminder.DB.EQUIP:GetInstanceSet(instanceType, selectedDifficulty)
                local label = (equipSetID and LoadoutReminder.EQUIP:GetEquipSetNameByID(equipSetID)) or nil
                return {
                    label = label,
                    value = equipSetID
                }
            end
        },
        SPEC = {
            Save = function(_, instanceType, specID)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                LoadoutReminder.DB.SPEC:SaveInstanceSet(instanceType, selectedDifficulty, specID)
            end,
            Get = function(_, instanceType)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                return LoadoutReminder.DB.SPEC:GetInstanceSet(instanceType, selectedDifficulty)
            end,
            GetInitialData = function(_, instanceType)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                local specID = LoadoutReminder.DB.SPEC:GetInstanceSet(instanceType, selectedDifficulty)
                local specName = specID and select(2, GetSpecializationInfoByID(specID)) or ""
                return {
                    label = specName,
                    value = specID
                }
            end
        },
        ADDONS = {
            Save = function(_, instanceType, addonSetID)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                LoadoutReminder.DB.ADDONS:SaveInstanceSet(instanceType, selectedDifficulty, addonSetID)
            end,
            Get = function(_, instanceType)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                return LoadoutReminder.DB.ADDONS:GetInstanceSet(instanceType, selectedDifficulty)
            end,
            GetInitialData = function(_, instanceType)
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                local setName = LoadoutReminder.DB.ADDONS:GetInstanceSet(instanceType, selectedDifficulty)
                return {
                    label = setName,
                    value = setName
                }
            end
        },
    }

    LoadoutReminder.OPTIONS.FRAMES:CreateTabListWithDropdowns(generalTab.content,
        LoadoutReminder.GUTIL:Filter(LoadoutReminder.CONST.INSTANCE_TYPES,
            function(it) return it ~= LoadoutReminder.CONST.INSTANCE_TYPES.RAID end),
        LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES, dropdownData, dbFunctions, 0, -20, nil, -30, 600, 460, 15,
        -20)

    -- ### RAIDS

    local raidsTab = LoadoutReminder.GGUI.BlizzardTab({
        buttonOptions =
        {
            label = "Raids",
            parent = LoadoutReminder.OPTIONS.frame.content,
            anchorParent = generalTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
        },
        canBeEnabled = true,
        parent = LoadoutReminder.OPTIONS.frame.content,
        anchorParent = LoadoutReminder.OPTIONS.frame.content,
        anchorA = "CENTER",
        anchorB = "CENTER",
        offsetX = 0,
        offsetY = tabOffsetY,
        sizeX = tabContentX,
        sizeY = tabContentY,
        top = true,
    })

    raidsTab.content.background = LoadoutReminder.GGUI.Frame {
        parent = raidsTab.content, anchorParent = raidsTab.content, sizeX = tabContentX, sizeY = tabContentY,
        backdropOptions = LoadoutReminder.CONST.OPTIONS_TAB_CONTENT_BACKDROP,
    }

    LoadoutReminder.OPTIONS.FRAMES:CreateRaidTabList(raidsTab.content, dropdownData)

    LoadoutReminder.GGUI.BlizzardTabSystem({ generalTab, raidsTab })
end

function LoadoutReminder.OPTIONS.FRAMES:CreateRaidTabList(parent, dropdownData)
    local tabContentX = 600
    local tabContentY = 460

    local tabs = {}

    local raids = LoadoutReminder.CONST.RAIDS

    local lastAnchor = parent
    local anchorB = "TOPLEFT"
    local setInitial = true
    local offsetY = -20
    local offsetX = 15
    for _, raid in GUTIL:OrderedPairs(raids, function(a, b)
        if a == LoadoutReminder.CONST.RAIDS.DEFAULT then
            return true
        else
            return false
        end
    end) do
        local label = LoadoutReminder.CONST.RAID_DISPLAY_NAMES[raid]
        local initialTab = setInitial
        local tab = LoadoutReminder.GGUI.BlizzardTab({
            buttonOptions =
            {
                label = label,
                parent = parent,
                anchorParent = lastAnchor,
                anchorA = "TOPLEFT",
                anchorB = anchorB,
                offsetX = offsetX,
                offsetY = offsetY,
            },
            canBeEnabled = true,
            parent = parent,
            anchorParent = parent,
            anchorA = "CENTER",
            anchorB = "CENTER",
            offsetX = 0,
            offsetY = -20,
            sizeX = tabContentX,
            sizeY = tabContentY,
            initialTab = initialTab,
            top = true,
        })

        setInitial = false

        tab.content.title = LoadoutReminder.GGUI.Text({
            parent = tab.content,
            anchorParent = tab.content,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = -20,
            text = label,
            offsetX = 0,
        })

        tab.content.background = LoadoutReminder.GGUI.Frame {
            parent = tab.content, anchorParent = tab.content, sizeX = tabContentX, sizeY = tabContentY,
            backdropOptions = LoadoutReminder.CONST.OPTIONS_TAB_CONTENT_BACKDROP,
        }

        local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder
            .CONST.INSTANCE_TYPES.RAID)

        local perBossOptionKey = LoadoutReminder.OPTIONS:GetPerBossOptionKey(selectedDifficulty, raid)

        if raid ~= LoadoutReminder.CONST.RAIDS.DEFAULT then
            ---@class LoadoutReminder.PerBossCheckbox : GGUI.Checkbox
            tab.content.perBossCheckbox = LoadoutReminder.GGUI.Checkbox({
                parent = tab.content,
                anchorParent = tab.content,
                anchorA = "TOP",
                anchorB = "TOP",
                offsetX = 55,
                offsetY = -16,
                initialValue = LoadoutReminder.DB.OPTIONS:Get("PER_BOSS_LOADOUTS")[perBossOptionKey],
                label = "Boss Loadouts",
                tooltip =
                "When this is checked, you will be reminded for individual bosses for the selected raid of the selected difficulty.",
                clickCallback = function(_, checked)
                    local difficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    local key = LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)
                    LoadoutReminder.DB.OPTIONS:Get("PER_BOSS_LOADOUTS")[key] = checked
                    LoadoutReminder.CHECK:CheckSituations()
                end
            })
            tab.content.perBossCheckbox.Reload = function()
                local difficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder
                    .CONST.INSTANCE_TYPES.RAID)
                local key = LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)
                tab.content.perBossCheckbox:SetChecked(LoadoutReminder.DB.OPTIONS:Get("PER_BOSS_LOADOUTS")[key])
            end
            table.insert(LoadoutReminder.OPTIONS.PERBOSSCHECKBOXES, tab.content.perBossCheckbox)

            tab.content.perBossCheckbox:Hide() -- cause initial difficulty is default and thats where we do not want the checkbox to show
        end

        local bosses = LoadoutReminder.GUTIL:Filter(LoadoutReminder.CONST.BOSS_ID_MAP, function(boss)
            return string.sub(boss, 1, string.len(raid)) == raid
        end)

        tinsert(bosses, 1, LoadoutReminder.CONST.BOSS_IDS.DEFAULT)

        bosses = LoadoutReminder.GUTIL:ToSet(bosses)
        bosses = LoadoutReminder.GUTIL:Sort(bosses, function(a, b)
            return LoadoutReminder.CONST.BOSS_SORT_ORDER[a] < LoadoutReminder.CONST.BOSS_SORT_ORDER[b]
        end)

        local dbFunctions = {
            TALENTS = {
                Save = function(_, bossID, talentSetID)
                    local specID = select(1, GetSpecializationInfo(GetSpecialization()))
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    LoadoutReminder.DB.TALENTS:SaveRaidBossSet(raid, bossID, selectedDifficulty, specID, talentSetID)
                end,
                Get = function(_, bossID)
                    local specID = select(1, GetSpecializationInfo(GetSpecialization()))
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    return LoadoutReminder.DB.TALENTS:GetRaidBossSet(raid, bossID, selectedDifficulty, specID)
                end,
                GetInitialData = function(_, bossID)
                    local specID = select(1, GetSpecializationInfo(GetSpecialization()))
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    local setID = LoadoutReminder.DB.TALENTS:GetRaidBossSet(raid, bossID, selectedDifficulty, specID)
                    local label = (setID and LoadoutReminder.TALENTS:GetTalentSetNameByID(setID)) or nil
                    return {
                        label = label,
                        value = setID
                    }
                end
            },
            EQUIP = {
                Save = function(_, bossID, equipSetID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    LoadoutReminder.DB.EQUIP:SaveRaidBossSet(raid, bossID, selectedDifficulty, equipSetID)
                end,
                Get = function(_, bossID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    return LoadoutReminder.DB.EQUIP:GetRaidBossSet(raid, bossID, selectedDifficulty)
                end,
                GetInitialData = function(_, bossID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    local setID = LoadoutReminder.DB.EQUIP:GetRaidBossSet(raid, bossID, selectedDifficulty)
                    local label = (setID and LoadoutReminder.EQUIP:GetEquipSetNameByID(setID)) or nil
                    return {
                        label = label,
                        value = setID
                    }
                end
            },
            SPEC = {
                Save = function(_, bossID, specID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    LoadoutReminder.DB.SPEC:SaveRaidBossSet(raid, bossID, selectedDifficulty, specID)
                end,
                Get = function(_, bossID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    return LoadoutReminder.DB.SPEC:GetRaidBossSet(raid, bossID, selectedDifficulty)
                end,
                GetInitialData = function(_, bossID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    local specID = LoadoutReminder.DB.SPEC:GetRaidBossSet(raid, bossID, selectedDifficulty)
                    local specName = specID and select(2, GetSpecializationInfoByID(specID)) or ""
                    return {
                        label = specName,
                        value = specID
                    }
                end
            },
            ADDONS = {
                Save = function(_, bossID, addonSetID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    LoadoutReminder.DB.ADDONS:SaveRaidBossSet(raid, bossID, addonSetID, selectedDifficulty)
                end,
                Get = function(_, bossID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    return LoadoutReminder.DB.ADDONS:GetRaidBossSet(raid, bossID, selectedDifficulty)
                end,
                GetInitialData = function(_, bossID)
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    local setName = LoadoutReminder.DB.ADDONS:GetRaidBossSet(raid, bossID, selectedDifficulty)
                    return {
                        label = setName,
                        value = setName
                    }
                end
            },
        }

        LoadoutReminder.OPTIONS.FRAMES:CreateTabListWithDropdowns(tab.content, bosses, LoadoutReminder.CONST.BOSS_NAMES,
            dropdownData, dbFunctions, 0, -30, 0, -60, 540, 380, 35, -40)
        table.insert(tabs, tab)
        --
        lastAnchor = tab.button
        anchorB = "TOPRIGHT"
        offsetY = 0
        offsetX = 0
    end

    LoadoutReminder.GGUI.BlizzardTabSystem(tabs)

    return tabs
end

function LoadoutReminder.OPTIONS.FRAMES:CreateTabListWithDropdowns(parent, idTable, nameTable, dropdownData, dbFunctions,
                                                                   baseOffsetX, baseOffsetY, titleOffsetX,
                                                                   titleOffsetY, tabContentX, tabContentY,
                                                                   tabButtonOffsetX, tabButtonOffsetY, tabsPerRow)
    tabsPerRow = tabsPerRow or 7

    baseOffsetX = baseOffsetX or 0
    baseOffsetY = baseOffsetY or 0
    titleOffsetX = titleOffsetX or 0
    titleOffsetY = titleOffsetY or (baseOffsetY - 20)

    local tabs = {}

    local lastAnchor = parent
    local anchorB = "TOPLEFT"
    local offsetY = tabButtonOffsetY
    local offsetX = tabButtonOffsetX
    local initialTab = true
    local currentTab = 1
    local currentRow = 1
    local lastButton = nil
    for _, tabID in pairs(idTable) do
        local label = nameTable[tabID]
        local tab = LoadoutReminder.GGUI.BlizzardTab({
            buttonOptions =
            {
                label = label,
                parent = parent,
                anchorParent = lastAnchor,
                anchorA = "TOPLEFT",
                anchorB = anchorB,
                offsetX = offsetX,
                offsetY = offsetY,
            },
            canBeEnabled = true,
            parent = parent,
            anchorParent = parent,
            anchorA = "CENTER",
            anchorB = "CENTER",
            offsetX = 0,
            offsetY = baseOffsetY,
            sizeX = tabContentX,
            sizeY = tabContentY,
            initialTab = initialTab,
            top = true,
        })


        tab.content.background = LoadoutReminder.GGUI.Frame {
            parent = tab.content, anchorParent = tab.content, sizeX = tabContentX, sizeY = tabContentY,
            backdropOptions = LoadoutReminder.CONST.OPTIONS_TAB_CONTENT_BACKDROP,
        }

        initialTab = false

        tab.content.title = LoadoutReminder.GGUI.Text({
            parent = tab.content,
            anchorParent = tab.content,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = titleOffsetY,
            text = label,
            offsetX = 0,
        })

        LoadoutReminder.OPTIONS.FRAMES:CreateReminderTypeDropdowns(tab.content, tab.content.title.frame, "TOP", "BOTTOM",
            0, -20,
            dropdownData, dbFunctions, tabID)
        table.insert(tabs, tab)
        --
        if lastButton then
            tab.button:SetFrameLevel(math.max(lastButton:GetFrameLevel() - 1, 1))
        end
        lastAnchor = tab.button
        lastButton = tab.button
        anchorB = "TOPRIGHT"
        offsetY = 0
        offsetX = 0

        if currentTab % tabsPerRow == 0 then
            currentRow = currentRow + 1
            lastAnchor = parent
            anchorB = "TOPLEFT"
            offsetY = tabButtonOffsetY + (10 * currentRow)
            offsetX = tabButtonOffsetX
        end

        currentTab = currentTab + 1
    end

    LoadoutReminder.GGUI.BlizzardTabSystem(tabs)

    return tabs
end

function LoadoutReminder.OPTIONS.FRAMES:CreateReminderTypeDropdowns(parent, anchorParent, anchorA, anchorB, offsetX,
                                                                    offsetY,
                                                                    dropdownData, dbFunctions, tabID)
    local dropdownSpacingY = -21
    local talentData = dropdownData.TALENTS
    local initialTalent = dbFunctions.TALENTS:GetInitialData(tabID)
    ---@type GGUI.Dropdown
    local talentsDropdown = LoadoutReminder.GGUI.Dropdown({
        parent = parent,
        anchorParent = anchorParent,
        anchorA = anchorA,
        anchorB = anchorB,
        offsetX = offsetX,
        offsetY = offsetY,
        label = "Talent Set",
        initialData = talentData,
        initialValue = initialTalent.value,
        initialLabel = initialTalent.label or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback = function(self, _, data)
            dbFunctions.TALENTS:Save(tabID, data)
            LoadoutReminder.CHECK:CheckSituations()
        end,
    })
    talentsDropdown.Reload = function(_, dropdownData)
        local initialData = dbFunctions.TALENTS:GetInitialData(tabID)
        talentsDropdown:SetData({
            data = dropdownData.TALENTS,
            initialValue = initialData.value,
            initialLabel =
                initialData.label or LoadoutReminder.CONST.LABEL_NO_SET
        })
    end
    local equipData = dropdownData.EQUIP
    local initialEquip = dbFunctions.EQUIP:GetInitialData(tabID)
    local equipDropdown = LoadoutReminder.GGUI.Dropdown({
        parent = parent,
        anchorParent = talentsDropdown.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetX = 0,
        offsetY = dropdownSpacingY,
        label = "Equip Set",
        initialData = equipData,
        initialValue = initialEquip.value,
        initialLabel = initialEquip.label or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback = function(self, _, data)
            dbFunctions.EQUIP:Save(tabID, data)
            LoadoutReminder.CHECK:CheckSituations()
        end,
    })
    equipDropdown.Reload = function(_, dropdownData)
        local initialData = dbFunctions.EQUIP:GetInitialData(tabID)
        equipDropdown:SetData({
            data = dropdownData.EQUIP,
            initialValue = initialData.value,
            initialLabel = initialData
                .label or LoadoutReminder.CONST.LABEL_NO_SET
        })
    end
    local specData = dropdownData.SPEC
    local initialSpec = dbFunctions.SPEC:GetInitialData(tabID)
    local specDropdown = LoadoutReminder.GGUI.Dropdown({
        parent = parent,
        anchorParent = equipDropdown.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetX = 0,
        offsetY = dropdownSpacingY,
        label = "Specialization",
        initialData = specData,
        initialValue = initialSpec.value,
        initialLabel = initialSpec.label or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback = function(self, _, value)
            dbFunctions.SPEC:Save(tabID, value)
            LoadoutReminder.CHECK:CheckSituations()
        end,
    })
    specDropdown.Reload = function(_, dropdownData)
        local initialData = dbFunctions.SPEC:GetInitialData(tabID)
        specDropdown:SetData({
            data = dropdownData.SPEC,
            initialValue = initialData.value,
            initialLabel = initialData
                .label or LoadoutReminder.CONST.LABEL_NO_SET
        })
    end

    table.insert(LoadoutReminder.OPTIONS.DROPDOWNS, talentsDropdown)
    table.insert(LoadoutReminder.OPTIONS.DROPDOWNS, equipDropdown)
    table.insert(LoadoutReminder.OPTIONS.DROPDOWNS, specDropdown)

    local addonData = dropdownData.ADDONS

    if not addonData then
        return
    end

    local initialAddons = dbFunctions.ADDONS:GetInitialData(tabID)
    local addonDropdown = LoadoutReminder.GGUI.Dropdown({
        parent = parent,
        anchorParent = specDropdown.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetX = 0,
        offsetY = dropdownSpacingY,
        label = "Addon Set",
        initialData = addonData,
        initialValue = initialAddons.value,
        initialLabel = initialAddons.label or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback = function(self, _, data)
            dbFunctions.ADDONS:Save(tabID, data)
            LoadoutReminder.CHECK:CheckSituations()
        end,
    })
    addonDropdown.Reload = function(_, dropdownData)
        local initialData = dbFunctions.ADDONS:GetInitialData(tabID)
        addonDropdown:SetData({
            data = dropdownData.ADDONS,
            initialValue = initialData.value,
            initialLabel = initialData
                .label or LoadoutReminder.CONST.LABEL_NO_SET
        })
    end


    table.insert(LoadoutReminder.OPTIONS.DROPDOWNS, addonDropdown)
end

function LoadoutReminder.OPTIONS.FRAMES:ReloadDropdowns()
    if not LoadoutReminder.INIT.READY then
        return
    end

    local dropdownData = {
        TALENTS = LoadoutReminder.OPTIONS:GetTalentsData(),
        EQUIP = LoadoutReminder.OPTIONS:GetEquipData(),
        SPEC = LoadoutReminder.OPTIONS:GetSpecData(),
        ADDONS = LoadoutReminder.OPTIONS:GetAddonsData()
    }

    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder
        .CONST.INSTANCE_TYPES.RAID)

    for _, dropdown in pairs(LoadoutReminder.OPTIONS.DROPDOWNS) do
        dropdown:Reload(dropdownData)
    end

    for _, checkBox in pairs(LoadoutReminder.OPTIONS.PERBOSSCHECKBOXES) do
        checkBox:Reload()
        checkBox:SetVisible(selectedDifficulty ~= LoadoutReminder.CONST.DIFFICULTY.DEFAULT)
    end
end