_, LoadoutReminder = ...

LoadoutReminder.OPTIONS = {}
LoadoutReminder.OPTIONS.DROPDOWNS = {
    TALENTS = {},
    ADDONS = {},
    EQUIP = {},
    SPECIALIZATIONS = {},
}

function LoadoutReminder.OPTIONS:GetTalentsData()
    -- #### TALENTS
    ---@type number|string[]
    local talentSetIDs = LoadoutReminder.TALENTS:GetTalentSets()

    -- convert to dropdown data, always include starter build label
    local talentsDropdownData = {
        {
            label=LoadoutReminder.CONST.LABEL_NO_SET,
            value=nil
        },
        {
            label=LoadoutReminder.CONST.STARTER_BUILD,
            value=Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID
        }
    }
    table.foreach(talentSetIDs, function(_, configID)
        local setName = LoadoutReminder.TALENTS:GetTalentSetNameByID(configID)
        table.insert(talentsDropdownData, {
            label=setName,
            value=configID,
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
            label=LoadoutReminder.CONST.LABEL_NO_SET,
            value=nil
        }
    }

    table.foreach(addonSets, function(setName, _)
        table.insert(addonsDropdownData, {
            label=setName,
            value=setName,
        })
    end)
    return addonsDropdownData
end
function LoadoutReminder.OPTIONS:GetEquipData()
    local equipSets = LoadoutReminder.EQUIP:GetEquipSets()

    -- convert to dropdown data, always include starter build label
    local equipDropdownData = {
        {
            label=LoadoutReminder.CONST.LABEL_NO_SET,
            value=nil
        }
    }

    table.foreach(equipSets, function(_, setID)
        local setName = LoadoutReminder.EQUIP:GetEquipSetNameByID(setID)
        table.insert(equipDropdownData, {
            label=setName,
            value=setID,
        })
    end)
    return equipDropdownData
end
function LoadoutReminder.OPTIONS:GetSpecData()
    local specs = LoadoutReminder.SPEC:GetSpecSets()

    -- convert to dropdown data, always include starter build label
    local specDropdownData = {
        {
            label=LoadoutReminder.CONST.LABEL_NO_SET,
            value=nil
        }
    }

    table.foreach(specs, function(_, setName)
        table.insert(specDropdownData, {
            label=setName,
            value=setName,
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

    local dropdownData = {
        TALENTS = LoadoutReminder.OPTIONS:GetTalentsData(),
        EQUIP = LoadoutReminder.OPTIONS:GetEquipData(),
        SPEC = LoadoutReminder.OPTIONS:GetSpecData(),
        ADDONS = LoadoutReminder.OPTIONS:GetAddonsData()
    }

    local tabContentX=623
    local tabContentY=500
    local tabOffsetY = -30

    --- GENERAL
    ---@type GGUI.Tab
    local generalTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="General", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=LoadoutReminder.OPTIONS.optionsPanel, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=20,offsetY=-20
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=tabOffsetY,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local dbFunctions = {
        TALENTS= {
            Save = function (_, tabID, data)
                LoadoutReminder.DB.TALENTS:SaveInstanceSet(tabID, data)
            end,
            Get = function (_, tabID)
                return LoadoutReminder.DB.TALENTS:GetInstanceSet(tabID)
            end
        },
        EQUIP= {
            Save = function (_, tabID, data)
                LoadoutReminder.DB.EQUIP:SaveInstanceSet(tabID, data)
            end,
            Get = function (_, tabID)
                return LoadoutReminder.DB.EQUIP:GetInstanceSet(tabID)
            end
        },
        SPEC= {
            Save = function (_, tabID, data)
                LoadoutReminder.DB.SPEC:SaveInstanceSet(tabID, data)
            end,
            Get = function (_, tabID)
                return LoadoutReminder.DB.SPEC:GetInstanceSet(tabID)
            end
        },
        ADDONS= {
            Save = function (_, tabID, data)
                LoadoutReminder.DB.ADDONS:SaveInstanceSet(tabID, data)
            end,
            Get = function (_, tabID)
                return LoadoutReminder.DB.ADDONS:GetInstanceSet(tabID)
            end
        },
    }

    LoadoutReminder.OPTIONS:CreateTabListWithDropdowns(generalTab.content, 
        LoadoutReminder.CONST.INSTANCE_TYPES, 
        LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES, dropdownData, dbFunctions, 100, 0, 35)

    -- ### RAIDS

    ---@type GGUI.Tab
    local raidsTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Raids", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=generalTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=tabOffsetY,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    LoadoutReminder.OPTIONS:CreateRaidTabList(raidsTab.content, dropdownData)

    LoadoutReminder.GGUI.TabSystem({generalTab, raidsTab})

    InterfaceOptions_AddCategory(self.optionsPanel)
end

function LoadoutReminder.OPTIONS:CreateRaidTabList(parent, dropdownData)
    local subTabSizeX= 100
    local tabContentX = 500
    local tabContentY = 500

    local tabs = {}

    local raids = LoadoutReminder.CONST.RAIDS
    
    local lastAnchor = parent
    local anchorB = "TOPLEFT"
    local offsetY = -20
    for _, raid in pairs(raids) do

        local label = LoadoutReminder.CONST.RAID_DISPLAY_NAMES[raid]
        local tab = LoadoutReminder.GGUI.Tab({
            buttonOptions=
            {
                label=label, parent=parent, anchorParent=lastAnchor,
                anchorA="TOPLEFT", anchorB=anchorB, offsetX=0,offsetY=offsetY, sizeY=20, sizeX=subTabSizeX
            },
            canBeEnabled=true,
            parent=parent,
            anchorParent=parent,
            anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
            sizeX=tabContentX, sizeY=tabContentY,
        })

        tab.content.title = LoadoutReminder.GGUI.Text({
            parent=tab.content,anchorParent=tab.content,anchorA="TOP", anchorB="TOP", offsetY=40, 
            text=label, offsetX=160,
        })

        local bosses = LoadoutReminder.GUTIL:Filter(LoadoutReminder.CONST.BOSS_ID_MAP, function (boss)
            return string.sub(boss, 1, string.len(raid)) == raid
        end)

        bosses = LoadoutReminder.GUTIL:ToSet(bosses)

        local dbFunctions = {
            TALENTS= {
                Save = function (_, tabID, data)
                    LoadoutReminder.DB.TALENTS:SaveRaidSet(raid, tabID, data)
                end,
                Get = function (_, tabID)
                    return LoadoutReminder.DB.TALENTS:GetRaidSet(raid, tabID)
                end
            },
            EQUIP= {
                Save = function (_, tabID, data)
                    LoadoutReminder.DB.EQUIP:SaveRaidSet(raid, tabID, data)
                end,
                Get = function (_, tabID)
                    return LoadoutReminder.DB.EQUIP:GetRaidSet(raid, tabID)
                end
            },
            SPEC= {
                Save = function (_, tabID, data)
                    LoadoutReminder.DB.SPEC:SaveRaidSet(raid, tabID, data)
                end,
                Get = function (_, tabID)
                    return LoadoutReminder.DB.SPEC:GetRaidSet(raid, tabID)
                end
            },
            ADDONS= {
                Save = function (_, tabID, data)
                    LoadoutReminder.DB.ADDONS:SaveRaidSet(raid, tabID, data)
                end,
                Get = function (_, tabID)
                    return LoadoutReminder.DB.ADDONS:GetRaidSet(raid, tabID)
                end
            },
        }

        LoadoutReminder.OPTIONS:CreateTabListWithDropdowns(tab.content, bosses, LoadoutReminder.CONST.BOSS_NAMES, dropdownData, dbFunctions, 200, 60, 0, 100, 15)
        table.insert(tabs, tab)
        --
        lastAnchor = tab.button.frame
        anchorB = "BOTTOMLEFT"
        offsetY = 0
    end

    LoadoutReminder.GGUI.TabSystem(tabs)

    return tabs
end

function LoadoutReminder.OPTIONS:CreateTabListWithDropdowns(parent, idTable, nameTable, dropdownData, dbFunctions, buttonWidth, baseOffsetX, baseOffsetY, titleOffsetX, titleOffsetY)
    local tabContentX = 500
    local tabContentY = 500

    baseOffsetX = baseOffsetX or 0
    baseOffsetY = baseOffsetY or 0
    titleOffsetX = titleOffsetX or 0
    titleOffsetY = titleOffsetY or (baseOffsetY-20)

    local tabs = {}

    local lastAnchor = parent
    local anchorB = "TOPLEFT"
    local offsetY = -20
    local offsetX = baseOffsetX
    for _, tabID in pairs(idTable) do
        local label = nameTable[tabID]
        local tab = LoadoutReminder.GGUI.Tab({
            buttonOptions=
            {
                label=label, parent=parent, anchorParent=lastAnchor,
                anchorA="TOPLEFT", anchorB=anchorB, offsetX=offsetX,offsetY=offsetY, sizeY=20, sizeX=buttonWidth
            },
            canBeEnabled=true,
            parent=parent,
            anchorParent=parent,
            anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
            sizeX=tabContentX, sizeY=tabContentY,
        })

        tab.content.title = LoadoutReminder.GGUI.Text({
            parent=tab.content,anchorParent=tab.content,anchorA="TOP", anchorB="TOP", offsetY=titleOffsetY, 
            text=label, offsetX=titleOffsetX+baseOffsetX,
        })
        LoadoutReminder.OPTIONS:CreateReminderTypeDropdowns(tab.content, tab.content.title.frame, "TOP", "BOTTOM", 0, -20, dropdownData, dbFunctions, tabID)
        table.insert(tabs, tab)
        --
        lastAnchor = tab.button.frame
        anchorB = "BOTTOMLEFT"
        offsetY = 0
        offsetX = 0
    end

    LoadoutReminder.GGUI.TabSystem(tabs)

    return tabs
end

function LoadoutReminder.OPTIONS:CreateReminderTypeDropdowns(parent, anchorParent, anchorA, anchorB, offsetX, offsetY, dropdownData, dbFunctions, tabID)
    local dropdownSpacingY = -21
    local talentData = dropdownData.TALENTS
    local talentSetID = dbFunctions.TALENTS:Get(tabID)
    local talentInitLabel = (talentSetID and LoadoutReminder.TALENTS:GetTalentSetNameByID(talentSetID)) or nil
    local talentInitValue = talentSetID
    ---@type GGUI.Dropdown
    local talentsDropdown = LoadoutReminder.GGUI.Dropdown({
        parent=parent, anchorParent=anchorParent,
        anchorA=anchorA,anchorB=anchorB, offsetX=offsetX,offsetY=offsetY,label="Talent Set",
        initialData=talentData, initialValue=talentInitValue, initialLabel=talentInitLabel or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback=function (self, _, data)
            dbFunctions.TALENTS:Save(tabID, data)
        end,
    })
    local equipData = dropdownData.EQUIP
    local equipSetID = dbFunctions.EQUIP:Get(tabID)
    local equipInitLabel = (equipSetID and LoadoutReminder.EQUIP:GetEquipSetNameByID(equipSetID)) or nil
    local equipInitValue = equipSetID
    local equipDropdown = LoadoutReminder.GGUI.Dropdown({
        parent=parent, anchorParent=talentsDropdown.frame,
        anchorA="TOP",anchorB="BOTTOM", offsetX=0,offsetY=dropdownSpacingY,label="Equip Set",
        initialData=equipData, initialValue=equipInitValue, initialLabel=equipInitLabel or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback=function (self, _, data)
            dbFunctions.EQUIP:Save(tabID, data)
        end,
    })
    local specData = dropdownData.SPEC
    local specInitLabel = dbFunctions.SPEC:Get(tabID)
    local specInitValue = specInitLabel
    local specDropdown = LoadoutReminder.GGUI.Dropdown({
        parent=parent, anchorParent=equipDropdown.frame,
        anchorA="TOP",anchorB="BOTTOM", offsetX=0,offsetY=dropdownSpacingY,label="Specialization",
        initialData=specData, initialValue=specInitValue, initialLabel=specInitLabel or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback=function (self, _, data)
            dbFunctions.SPEC:Save(tabID, data)
        end,
    })

    local addonData = dropdownData.ADDONS

    if not addonData then
        return
    end

    local addonInitLabel = dbFunctions.ADDONS:Get(tabID)
    local addonInitValue = addonInitLabel
    local addonDropdown = LoadoutReminder.GGUI.Dropdown({
        parent=parent, anchorParent=specDropdown.frame,
        anchorA="TOP",anchorB="BOTTOM", offsetX=0,offsetY=dropdownSpacingY,label="Addon Set",
        initialData=addonData, initialValue=addonInitValue, initialLabel=addonInitLabel or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback=function (self, _, data)
            dbFunctions.ADDONS:Save(tabID, data)
        end,
    })

end

--- legacy:

---@param tab GGUI.Tab
---@param dropdownData GGUI.DropdownData
---@param generalSaveTable table
---@param bossSaveTable table
---@param bossToggleSaveTable table
---@param savePerSpecID boolean
function LoadoutReminder.OPTIONS:CreateTabOptionsForType(tab, dropdownData, savePerSpecID, generalSaveTable, bossSaveTable, bossToggleSaveTable, configNameFunction)
    local typeTabContentX=500
    local typeTabContentY=500

    local playerSpecID = GetSpecialization()

    local dropdowns = {}

    ---@type GGUI.Tab
    tab.generalTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="General", parent=tab.content, anchorParent=tab.content, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=-63,offsetY=-20
        },
        canBeEnabled=true,
        parent=tab.content,
        anchorParent=tab.content,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=typeTabContentX, sizeY=typeTabContentY,
    })
    ---@type GGUI.Tab
    tab.raidsTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Raids", parent=tab.content, anchorParent=tab.generalTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=tab.content,
        anchorParent=tab.content,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=typeTabContentX, sizeY=typeTabContentY,
    })

    local function dropdownClickCallbackInstanceTypes(setID, setIdentifier)
        if savePerSpecID then
            local playerSpecID = GetSpecialization()
            generalSaveTable[playerSpecID][setID] = setIdentifier
        else
            generalSaveTable[setID] = setIdentifier
        end
        LoadoutReminder.MAIN:CheckSituations()
    end

    local generalDropdownSpacingX = 200
    local generalDropdownSpacingY = -60
    local generalDropdownBaseOffsetX = -80
    local generalDropdownBaseOffsetY = -80
    tab.dropdowns = {
        INSTANCES = {},
        RAID_BOSSES = {},
    }
    -- Instance Types
    local function createInstanceDropdown(saveTable, savePerSpecID, instanceType, parent, offsetX, offsetY)

        local initialLabel = (savePerSpecID and saveTable[playerSpecID][instanceType]) or saveTable[instanceType]
        local initialValue = nil
        -- get config name from supposed ID (e.g. Talents) or use name directly
        if initialLabel and configNameFunction then
            initialValue = initialLabel
            initialLabel = configNameFunction(self, initialLabel)
        else
            initialValue = initialLabel
        end
        ---@type GGUI.Dropdown
        tab.dropdowns.INSTANCES[instanceType] = LoadoutReminder.GGUI.Dropdown({
        parent=parent, anchorParent=parent,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=offsetX,offsetY=offsetY,label=LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType],
        initialData=dropdownData, initialValue=initialValue, initialLabel=initialLabel or LoadoutReminder.CONST.LABEL_NO_SET,
        clickCallback=function (self, _, data)
            dropdownClickCallbackInstanceTypes(instanceType, data)
        end,
        })
    end

    local currentX = 1
    local currentY = 1
    local width = 4
    for _, instanceType in pairs(LoadoutReminder.CONST.INSTANCE_TYPES) do
        createInstanceDropdown(generalSaveTable, savePerSpecID, 
        instanceType, tab.generalTab.content,
        generalDropdownBaseOffsetX + generalDropdownSpacingX*(currentX-1), generalDropdownBaseOffsetY + generalDropdownSpacingY*(currentY-1))
        currentX = currentX + 1
        if currentX % width == 0 then
            currentY = currentY + 1
            currentX = 1
        end
    end

    local subTabContentX = 400
    local subTabContentY = 400

    local function dropdownClickCallbackBosses(setID, setName)
        if savePerSpecID then
            local playerSpecID = GetSpecialization()
            bossSaveTable[playerSpecID][setID] = setName
        else
            bossSaveTable[setID] = setName
        end
        LoadoutReminder.MAIN:CheckSituations()
    end
    local function createRaidDropdowns(raidTab, raid)
        local bossDropdownSpacingX = 200
        local bossDropdownSpacingY = -60
        local bossDropdownBaseOffsetX = -128
        local bossDropdownBaseOffsetY = -100
    
        LoadoutReminder.GGUI.Checkbox({label='Per Boss', parent=raidTab.content, anchorParent=raidTab.content,
        anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX= -113, offsetY=-55, initialValue=bossToggleSaveTable[raid] ,clickCallback=function (_, checked)
            bossToggleSaveTable[raid] = checked
            -- TODO: maybe disable/hide dropdowns if not checked
        end})
    
        -- Bosses
        local function createBossDropdown(saveTable, savePerSpecID, boss, parent, offsetX, offsetY)
            local initialLabel =(savePerSpecID and saveTable[playerSpecID][boss]) or saveTable[boss]
            local initialValue = nil
            -- get config name from supposed ID (e.g. Talents) or use name directly
            if initialLabel and configNameFunction then
                initialValue = initialLabel
                initialLabel = configNameFunction(self, initialLabel)
            else
                initialValue = initialLabel
            end
            ---@type GGUI.Dropdown
            tab.dropdowns.RAID_BOSSES[boss] = LoadoutReminder.GGUI.Dropdown({
            parent=parent, anchorParent=parent,
            anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=offsetX,offsetY=offsetY,label=LoadoutReminder.CONST.BOSS_NAMES[boss],
            initialData=dropdownData, initialValue=initialValue, initialLabel=initialLabel or LoadoutReminder.CONST.LABEL_NO_SET,
            clickCallback=function (self, _, data)
                dropdownClickCallbackBosses(boss, data)
            end,
        })
        end
    
        local bosses = LoadoutReminder.GUTIL:Filter(LoadoutReminder.CONST.BOSS_ID_MAP, function (boss)
            return string.sub(boss, 1, string.len(raid)) == raid
        end)

        bosses = LoadoutReminder.GUTIL:ToSet(bosses)
    
        currentX = 1
        currentY = 1
        width = 4
        for _, boss in pairs(bosses) do
            createBossDropdown(bossSaveTable, savePerSpecID, boss, raidTab.content, 
            bossDropdownBaseOffsetX + bossDropdownSpacingX*(currentX-1), bossDropdownBaseOffsetY+bossDropdownSpacingY*(currentY-1))
            currentX = currentX + 1
            if currentX % width == 0 then
                currentY = currentY + 1
                currentX = 1
            end
        end
    end

    ---@type GGUI.Tab
    tab.raidsTab.content.amirdrassilTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Amirdrassil", parent=tab.raidsTab.content, anchorParent=tab.generalTab.button.frame, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=0,offsetY=-40
        },
        canBeEnabled=true,
        parent=tab.raidsTab.content,
        anchorParent=tab.raidsTab.content,
        anchorA="TOP", anchorB="TOP", offsetX=0,offsetY=-40,
        sizeX=subTabContentX, sizeY=subTabContentY,
    })

    local amirdrassilTab = tab.raidsTab.content.amirdrassilTab

    ---@type GGUI.Tab
    tab.raidsTab.content.aberrusTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Aberrus", parent=tab.raidsTab.content, anchorParent=amirdrassilTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,offsetY=0
        },
        canBeEnabled=true,
        parent=tab.raidsTab.content,
        anchorParent=tab.raidsTab.content,
        anchorA="TOP", anchorB="TOP", offsetX=0,offsetY=-40,
        sizeX=subTabContentX, sizeY=subTabContentY,
    })

    local aberrusTab = tab.raidsTab.content.aberrusTab

    createRaidDropdowns(amirdrassilTab, LoadoutReminder.CONST.RAIDS.AMIRDRASSIL)
    createRaidDropdowns(aberrusTab, LoadoutReminder.CONST.RAIDS.ABERRUS)
    
    LoadoutReminder.GGUI.TabSystem({amirdrassilTab, aberrusTab})
    LoadoutReminder.GGUI.TabSystem({tab.generalTab, tab.raidsTab})

    return dropdowns
end

function LoadoutReminder.OPTIONS:ReloadDropdowns()

    -- debug
    if true then
        return
    end

    -- only if everything is initialized
    if not LoadoutReminder.MAIN.READY then
        return
    end

    local playerSpecID = GetSpecialization()

    local bySpecIDTabs = {
        TALENTS = {LoadoutReminder.OPTIONS.optionsPanel.generalTab, LoadoutReminder.OPTIONS:GetTalentsData(), LoadoutReminder.TALENTS.GetTalentSetNameByID}
    }

    local normalTabs = {
        ADDONS = (LoadoutReminder.ADDONS.AVAILABLE and {LoadoutReminder.OPTIONS.optionsPanel.raidsTab, LoadoutReminder.OPTIONS:GetAddonsData()}) or nil,
        EQUIP = {LoadoutReminder.OPTIONS.optionsPanel.equipTab, LoadoutReminder.OPTIONS:GetEquipData(), LoadoutReminder.EQUIP.GetEquipSetNameByID},
        SPEC = {LoadoutReminder.OPTIONS.optionsPanel.specTab, LoadoutReminder.OPTIONS:GetSpecData()}
    }
    -- instanceTypes
    for _, instanceType in pairs(LoadoutReminder.CONST.INSTANCE_TYPES) do
        for reminderType, data in pairs(bySpecIDTabs) do
            local tab = data[1]
            if tab then
                local dropdownData = data[2]
                local configNameFunction = data[3]

                local initialLabel = LoadoutReminderDBV3[reminderType].GENERAL[playerSpecID][instanceType]
                local initialValue = nil
                -- get config name from supposed ID (e.g. Talents) or use name directly
                if initialLabel and configNameFunction then
                    initialValue = initialLabel
                    initialLabel = configNameFunction(self, initialLabel)
                else
                    initialValue = initialLabel
                end

                local instanceDropdown = tab.dropdowns.INSTANCES[instanceType]

                
                instanceDropdown:SetData({data=dropdownData, initialValue= initialValue, initialLabel=initialLabel or LoadoutReminder.CONST.LABEL_NO_SET})
            end
        end

        for reminderType, data in pairs(normalTabs) do
            local tab = data[1]
            if tab then
                local dropdownData = data[2]
                local configNameFunction = data[3]

                local instanceDropdown = tab.dropdowns.INSTANCES[instanceType]
                local initialLabel = LoadoutReminderDBV3[reminderType].GENERAL[instanceType]
                local initialValue = nil

                if initialLabel and configNameFunction then
                    initialValue = initialLabel
                    initialLabel = configNameFunction(self, initialLabel)
                else
                    initialValue = initialLabel
                end
                
                instanceDropdown:SetData({data=dropdownData, initialValue=initialValue, initialLabel=initialLabel or LoadoutReminder.CONST.LABEL_NO_SET})
            end
        end
    end

    -- bosses
    for boss, _ in pairs(LoadoutReminder.CONST.BOSS_NAMES) do
        for reminderType, data in pairs(bySpecIDTabs) do
            local tab = data[1]

            if tab then
                local dropdownData = data[2]
                local configNameFunction = data[3]
                
                local initialLabel =LoadoutReminderDBV3[reminderType].BOSS[playerSpecID][boss]
                local initialValue = nil
                -- get config name from supposed ID (e.g. Talents) or use name directly
                if initialLabel and configNameFunction then
                    initialValue = initialLabel
                    initialLabel = configNameFunction(self, initialLabel)
                else
                    initialValue = initialLabel
                end
                
                local instanceDropdown = tab.dropdowns.RAID_BOSSES[boss]
                
                instanceDropdown:SetData({data=dropdownData, initialValue= initialValue, initialLabel=initialLabel or LoadoutReminder.CONST.LABEL_NO_SET})
            end
        end
        
        for reminderType, data in pairs(normalTabs) do
            local tab = data[1]
            if tab then
                local dropdownData = data[2]
                local configNameFunction = data[3]

                local instanceDropdown = tab.dropdowns.RAID_BOSSES[boss]
                local initialLabel = LoadoutReminderDBV3[reminderType].BOSS[boss]
                local initialValue = nil

                if initialLabel and configNameFunction then
                    initialValue = initialLabel
                    initialLabel = configNameFunction(self, initialLabel)
                else
                    initialValue = initialLabel
                end
                
                instanceDropdown:SetData({data=dropdownData, initialValue=initialValue, initialLabel=initialLabel or LoadoutReminder.CONST.LABEL_NO_SET})
            end
        end
    end


end
