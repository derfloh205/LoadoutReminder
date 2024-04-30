---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

LoadoutReminder.OPTIONS = {}
LoadoutReminder.OPTIONS.DROPDOWNS = {}
LoadoutReminder.OPTIONS.PERBOSSCHECKBOXES = {}
LoadoutReminder.OPTIONS.HELPICONS_DEFAULT_RAID = {}
LoadoutReminder.OPTIONS.HELPICONS_DEFAULT_DIFF = {}

function LoadoutReminder.OPTIONS:GetTalentsData()
    -- #### TALENTS
    ---@type number|string[]
    local talentSetIDs = LoadoutReminder.TALENTS:GetTalentSets()

    -- convert to dropdown data, always include starter build label
    local talentsDropdownData = {
        {
            label = LoadoutReminder.CONST.LABEL_NO_SET,
            value = nil
        },
        {
            label = LoadoutReminder.CONST.STARTER_BUILD,
            value = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID
        }
    }
    table.foreach(talentSetIDs, function(_, configID)
        local setName = LoadoutReminder.TALENTS:GetTalentSetNameByID(configID)
        table.insert(talentsDropdownData, {
            label = setName,
            value = configID,
        })
    end)
    return talentsDropdownData
end

function LoadoutReminder.OPTIONS:GetAddonsData()
    if not LoadoutReminder.ADDONS.AVAILABLE then
        return nil
    end
    local addonSets = LoadoutReminder.ADDONS:GetAddonSets()

    -- convert to dropdown data, always include starter build label
    local addonsDropdownData = {
        {
            label = LoadoutReminder.CONST.LABEL_NO_SET,
            value = nil
        }
    }

    table.foreach(addonSets, function(setName, _)
        table.insert(addonsDropdownData, {
            label = setName,
            value = setName,
        })
    end)
    return addonsDropdownData
end

function LoadoutReminder.OPTIONS:GetEquipData()
    local equipSets = LoadoutReminder.EQUIP:GetEquipSets()

    -- convert to dropdown data, always include starter build label
    local equipDropdownData = {
        {
            label = LoadoutReminder.CONST.LABEL_NO_SET,
            value = nil
        }
    }

    table.foreach(equipSets, function(_, setID)
        local setName = LoadoutReminder.EQUIP:GetEquipSetNameByID(setID)
        table.insert(equipDropdownData, {
            label = setName,
            value = setID,
        })
    end)
    return equipDropdownData
end

function LoadoutReminder.OPTIONS:GetSpecData()
    local specs = LoadoutReminder.SPEC:GetSpecSets()

    -- convert to dropdown data, always include starter build label
    local specDropdownData = {
        {
            label = LoadoutReminder.CONST.LABEL_NO_SET,
            value = nil
        }
    }

    table.foreach(specs, function(_, setName)
        table.insert(specDropdownData, {
            label = setName,
            value = setName,
        })
    end)
    return specDropdownData
end

function LoadoutReminder.OPTIONS:Init()
    LoadoutReminder.OPTIONS.optionsPanel = CreateFrame("Frame", "LoadoutReminderOptionsPanel")

    LoadoutReminder.OPTIONS.optionsPanel:HookScript("OnShow", function(self)
    end)

    LoadoutReminder.OPTIONS.optionsPanel.name = "Loadout Reminder"
    local title = LoadoutReminder.OPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
    title:SetText("Loadout Reminder Options")

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
        parent = LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent = LoadoutReminder.OPTIONS.optionsPanel,
        offsetY = -30,
        anchorA = "TOP",
        anchorB = "TOP",
        label = "Difficulty",
        initialData = difficultyDropdownData,
        initialLabel = LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES.DEFAULT,
        initialValue = LoadoutReminder.CONST.DIFFICULTY.DEFAULT,
        clickCallback = function()
            LoadoutReminder.OPTIONS:ReloadDropdowns()
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
            parent = LoadoutReminder.OPTIONS.optionsPanel,
            anchorParent = LoadoutReminder.OPTIONS.optionsPanel,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            offsetX = 25,
            offsetY = -35
        },
        canBeEnabled = true,
        parent = LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent = LoadoutReminder.OPTIONS.optionsPanel,
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
                local specID = GetSpecialization()
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                LoadoutReminder.DB.TALENTS:SaveInstanceSet(instanceType, selectedDifficulty, specID, talentSetID)
            end,
            Get = function(_, instanceType)
                local specID = GetSpecialization()
                local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                    instanceType)
                return LoadoutReminder.DB.TALENTS:GetInstanceSet(instanceType, selectedDifficulty, specID)
            end,
            GetInitialData = function(_, instanceType)
                local specID = GetSpecialization()
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
            Save = function(_, instanceType, data)
                LoadoutReminder.DB_old.EQUIP:SaveInstanceSet(instanceType, data)
            end,
            Get = function(_, instanceType)
                return LoadoutReminder.DB_old.EQUIP:GetInstanceSet(instanceType,
                    LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType))
            end,
            GetInitialData = function(_, instanceType)
                local equipSetID = LoadoutReminder.DB_old.EQUIP:GetInstanceSet(instanceType,
                    LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType))
                local label = (equipSetID and LoadoutReminder.EQUIP:GetEquipSetNameByID(equipSetID)) or nil
                return {
                    label = label,
                    value = equipSetID
                }
            end
        },
        SPEC = {
            Save = function(_, instanceType, data)
                LoadoutReminder.DB_old.SPEC:SaveInstanceSet(instanceType, data)
            end,
            Get = function(_, instanceType)
                return LoadoutReminder.DB_old.SPEC:GetInstanceSet(instanceType,
                    LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType))
            end,
            GetInitialData = function(_, instanceType)
                local setName = LoadoutReminder.DB_old.SPEC:GetInstanceSet(instanceType,
                    LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType))
                return {
                    label = setName,
                    value = setName
                }
            end
        },
        ADDONS = {
            Save = function(_, instanceType, data)
                LoadoutReminder.DB_old.ADDONS:SaveInstanceSet(instanceType, data)
            end,
            Get = function(_, instanceType)
                return LoadoutReminder.DB_old.ADDONS:GetInstanceSet(instanceType,
                    LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType))
            end,
            GetInitialData = function(_, instanceType)
                local setName = LoadoutReminder.DB_old.ADDONS:GetInstanceSet(instanceType,
                    LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType))
                return {
                    label = setName,
                    value = setName
                }
            end
        },
    }

    LoadoutReminder.OPTIONS:CreateTabListWithDropdowns(generalTab.content,
        LoadoutReminder.GUTIL:Filter(LoadoutReminder.CONST.INSTANCE_TYPES,
            function(it) return it ~= LoadoutReminder.CONST.INSTANCE_TYPES.RAID end),
        LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES, dropdownData, dbFunctions, 0, -20, nil, -30, 600, 460, 15,
        -20)

    -- ### RAIDS

    local raidsTab = LoadoutReminder.GGUI.BlizzardTab({
        buttonOptions =
        {
            label = "Raids",
            parent = LoadoutReminder.OPTIONS.optionsPanel,
            anchorParent = generalTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
        },
        canBeEnabled = true,
        parent = LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent = LoadoutReminder.OPTIONS.optionsPanel,
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

    LoadoutReminder.OPTIONS:CreateRaidTabList(raidsTab.content, dropdownData)

    LoadoutReminder.GGUI.BlizzardTabSystem({ generalTab, raidsTab })

    InterfaceOptions_AddCategory(self.optionsPanel)
end

function LoadoutReminder.OPTIONS:CreateRaidTabList(parent, dropdownData)
    local tabContentX = 600
    local tabContentY = 460

    local tabs = {}

    local raids = LoadoutReminder.CONST.RAIDS

    local lastAnchor = parent
    local anchorB = "TOPLEFT"
    local setInitial = true
    local offsetY = -20
    local offsetX = 15
    for _, raid in pairs(raids) do
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
                initialValue = LoadoutReminderOptionsV2[perBossOptionKey],
                label = "Boss Loadouts",
                tooltip =
                "When this is checked, you will be reminded for individual bosses for the selected raid of the selected difficulty.",
                clickCallback = function(_, checked)
                    local difficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    local key = LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)
                    LoadoutReminderOptionsV2[key] = checked
                    LoadoutReminder.CHECK:CheckSituations()
                end
            })
            tab.content.perBossCheckbox.Reload = function()
                local difficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder
                    .CONST.INSTANCE_TYPES.RAID)
                local key = LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)
                tab.content.perBossCheckbox:SetChecked(LoadoutReminderOptionsV2[key])
            end
            table.insert(LoadoutReminder.OPTIONS.PERBOSSCHECKBOXES, tab.content.perBossCheckbox)

            tab.content.perBossCheckbox:Hide() -- cause initial difficulty is default and thats where we do not want the checkbox to show

            ---@class GGUI.HelpIcon
            table.insert(LoadoutReminder.OPTIONS.HELPICONS_DEFAULT_DIFF,
                LoadoutReminder.GGUI.HelpIcon({
                    parent = tab.content,
                    anchorParent = tab.content,
                    anchorA = "TOP",
                    anchorB = "TOP",
                    offsetX = 50,
                    offsetY = -13,
                    text =
                        "You will be reminded of this loadouts when loading into the selected raid of any difficulty\nwhere individual boss loadouts are toggled" ..
                        LoadoutReminder.GUTIL:ColorizeText(" ON", LoadoutReminder.GUTIL.COLORS.GREEN),
                }))
        else
            table.insert(LoadoutReminder.OPTIONS.HELPICONS_DEFAULT_RAID,
                LoadoutReminder.GGUI.HelpIcon({
                    parent = tab.content,
                    anchorParent = tab.content,
                    anchorA = "TOP",
                    anchorB = "TOP",
                    offsetX = 50,
                    offsetY = -13,
                    text =
                        "You will be reminded of this loadout when loading into any raid (of the selected difficulty)\nwhere individual boss loadouts are toggled" ..
                        LoadoutReminder.GUTIL:ColorizeText(" OFF", LoadoutReminder.GUTIL.COLORS.RED),
                }))
        end

        local bosses = LoadoutReminder.GUTIL:Filter(LoadoutReminder.CONST.BOSS_ID_MAP, function(boss)
            return string.sub(boss, 1, string.len(raid)) == raid
        end)

        bosses = LoadoutReminder.GUTIL:ToSet(bosses)
        bosses = LoadoutReminder.GUTIL:Sort(bosses, function(a, b)
            return LoadoutReminder.CONST.BOSS_SORT_ORDER[a] < LoadoutReminder.CONST.BOSS_SORT_ORDER[b]
        end)

        local dbFunctions = {
            TALENTS = {
                Save = function(_, bossID, talentSetID)
                    local specID = GetSpecialization()
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    LoadoutReminder.DB.TALENTS:SaveRaidBossSet(raid, bossID, selectedDifficulty, specID, talentSetID)
                end,
                Get = function(_, bossID)
                    local specID = GetSpecialization()
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    return LoadoutReminder.DB.TALENTS:GetRaidBossSet(raid, bossID, selectedDifficulty, specID)
                end,
                GetInitialData = function(_, bossID)
                    local specID = GetSpecialization()
                    local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(
                        LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
                    local setID = LoadoutReminder.DB_old.TALENTS:GetRaidBossSet(raid, bossID, selectedDifficulty, specID)
                    local label = (setID and LoadoutReminder.TALENTS:GetTalentSetNameByID(setID)) or nil
                    return {
                        label = label,
                        value = setID
                    }
                end
            },
            EQUIP = {
                Save = function(_, bossID, data)
                    LoadoutReminder.DB_old.EQUIP:SaveRaidSet(raid, bossID, data)
                end,
                Get = function(_, bossID)
                    return LoadoutReminder.DB_old.EQUIP:GetRaidSet(raid, bossID,
                        LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST
                            .INSTANCE_TYPES.RAID))
                end,
                GetInitialData = function(_, bossID)
                    local setID = LoadoutReminder.DB_old.EQUIP:GetRaidSet(raid, bossID,
                        LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST
                            .INSTANCE_TYPES.RAID))
                    local label = (setID and LoadoutReminder.EQUIP:GetEquipSetNameByID(setID)) or nil
                    return {
                        label = label,
                        value = setID
                    }
                end
            },
            SPEC = {
                Save = function(_, bossID, data)
                    LoadoutReminder.DB_old.SPEC:SaveRaidSet(raid, bossID, data)
                end,
                Get = function(_, bossID)
                    return LoadoutReminder.DB_old.SPEC:GetRaidSet(raid, bossID,
                        LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST
                            .INSTANCE_TYPES.RAID))
                end,
                GetInitialData = function(_, bossID)
                    local setName = LoadoutReminder.DB_old.SPEC:GetRaidSet(raid, bossID,
                        LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST
                            .INSTANCE_TYPES.RAID))
                    return {
                        label = setName,
                        value = setName
                    }
                end
            },
            ADDONS = {
                Save = function(_, bossID, data)
                    LoadoutReminder.DB_old.ADDONS:SaveRaidSet(raid, bossID, data)
                end,
                Get = function(_, bossID)
                    return LoadoutReminder.DB_old.ADDONS:GetRaidSet(raid, bossID,
                        LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST
                            .INSTANCE_TYPES.RAID))
                end,
                GetInitialData = function(_, bossID)
                    local setName = LoadoutReminder.DB_old.ADDONS:GetRaidSet(raid, bossID,
                        LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST
                            .INSTANCE_TYPES.RAID))
                    return {
                        label = setName,
                        value = setName
                    }
                end
            },
        }

        LoadoutReminder.OPTIONS:CreateTabListWithDropdowns(tab.content, bosses, LoadoutReminder.CONST.BOSS_NAMES,
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

function LoadoutReminder.OPTIONS:CreateTabListWithDropdowns(parent, idTable, nameTable, dropdownData, dbFunctions,
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

        LoadoutReminder.OPTIONS:CreateReminderTypeDropdowns(tab.content, tab.content.title.frame, "TOP", "BOTTOM", 0, -20,
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

function LoadoutReminder.OPTIONS:CreateReminderTypeDropdowns(parent, anchorParent, anchorA, anchorB, offsetX, offsetY,
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
        clickCallback = function(self, _, data)
            dbFunctions.SPEC:Save(tabID, data)
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

function LoadoutReminder.OPTIONS:ReloadDropdowns()
    if not LoadoutReminder.MAIN.READY then
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

    for _, helpIcon in pairs(LoadoutReminder.OPTIONS.HELPICONS_DEFAULT_DIFF) do
        helpIcon:SetVisible(selectedDifficulty == LoadoutReminder.CONST.DIFFICULTY.DEFAULT)
    end
end

function LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType)
    local difficulty = "DEFAULT"
    if LoadoutReminder.UTIL:InstanceTypeSupportsDifficulty(instanceType) then
        difficulty = LoadoutReminder.OPTIONS.difficultyDropdown.selectedValue
    end
    return difficulty
end

function LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)
    return difficulty .. "_" .. raid .. "_PerBoss"
end

function LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss()
    local raid = LoadoutReminder.UTIL:GetCurrentRaid()
    if not raid then
        return false
    end
    local difficulty = LoadoutReminder.UTIL:GetInstanceDifficulty()
    if not difficulty then
        -- happens on first execution after going into a raid.. next exec should include difficulty
        return false
    end
    local optionKey = LoadoutReminder.OPTIONS:GetPerBossOptionKey(difficulty, raid)

    return LoadoutReminderOptionsV2[optionKey]
end
