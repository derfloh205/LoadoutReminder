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
    local talentSets = LoadoutReminder.TALENTS:GetTalentSets()

    -- convert to dropdown data, always include starter build label
    local talentsDropdownData = {
        {
            label='-',
            value=nil
        },
        {
            label=LoadoutReminder.CONST.STARTER_BUILD,
            value=LoadoutReminder.CONST.STARTER_BUILD
        }
    }
    table.foreach(talentSets, function(_, configInfo)
        table.insert(talentsDropdownData, {
            label=configInfo.name,
            value=configInfo.name,
        })
    end)
    return talentsDropdownData
end

function LoadoutReminder.OPTIONS:GetAddonsData()
    local addonSets = LoadoutReminder.ADDONS:GetAddonSets()

    -- convert to dropdown data, always include starter build label
    local addonsDropdownData = {
        {
            label='-',
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
            label='-',
            value=nil
        }
    }

    table.foreach(equipSets, function(_, setName)
        table.insert(equipDropdownData, {
            label=setName,
            value=setName,
        })
    end)
    return equipDropdownData
end
function LoadoutReminder.OPTIONS:GetSpecData()
    local specs = LoadoutReminder.SPEC:GetSpecSets()

    -- convert to dropdown data, always include starter build label
    local specDropdownData = {
        {
            label='-',
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
function LoadoutReminder.OPTIONS:Init(reload)

    LoadoutReminder.OPTIONS.optionsPanel = CreateFrame("Frame", "LoadoutReminderOptionsPanel")

	LoadoutReminder.OPTIONS.optionsPanel:HookScript("OnShow", function(self)
		end)

    LoadoutReminder.OPTIONS.optionsPanel.name = "Loadout Reminder"
	local title = LoadoutReminder.OPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("Loadout Reminder Options")

    local tabContentX=500
    local tabContentY=500

    ---@type GGUI.Tab
    LoadoutReminder.OPTIONS.optionsPanel.talentsTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Talents", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=LoadoutReminder.OPTIONS.optionsPanel, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=20,offsetY=-20
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local talentsDropdownData = LoadoutReminder.OPTIONS:GetTalentsData()
    
    LoadoutReminder.OPTIONS:CreateTabOptionsForType(LoadoutReminder.OPTIONS.optionsPanel.talentsTab, talentsDropdownData, true, 
        LoadoutReminderDB.TALENTS.GENERAL, LoadoutReminderDB.TALENTS.BOSS, 
        LoadoutReminderOptions.TALENTS.RAIDS_PER_BOSS)

    -- ### ADDONS

    ---@type GGUI.Tab
    LoadoutReminder.OPTIONS.optionsPanel.addonsTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Addons", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=LoadoutReminder.OPTIONS.optionsPanel.talentsTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    -- Only continue if any optional dependency is loaded, otherwise show text TODO: Move to end
    if not LoadoutReminder.ADDONS:Init() then
        LoadoutReminder.GGUI.Text({parent=LoadoutReminder.OPTIONS.optionsPanel.addonsTab.content, anchorParent=LoadoutReminder.OPTIONS.optionsPanel.addonsTab.content, text="No Addon Management Addon loaded."})
    else
        local addonsDropdownData = LoadoutReminder.OPTIONS:GetAddonsData()

        LoadoutReminder.OPTIONS:CreateTabOptionsForType(LoadoutReminder.OPTIONS.optionsPanel.addonsTab, addonsDropdownData, false, 
        LoadoutReminderDB.ADDONS.GENERAL, LoadoutReminderDB.ADDONS.BOSS, 
        LoadoutReminderOptions.ADDONS.RAIDS_PER_BOSS)
    end

    -- #### EQUIPMENT

    ---@type GGUI.Tab
    LoadoutReminder.OPTIONS.optionsPanel.equipTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Equipment", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=LoadoutReminder.OPTIONS.optionsPanel.addonsTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local equipDropdownData = LoadoutReminder.OPTIONS:GetEquipData()

    LoadoutReminder.OPTIONS:CreateTabOptionsForType(LoadoutReminder.OPTIONS.optionsPanel.equipTab, equipDropdownData, false, 
        LoadoutReminderDB.EQUIP.GENERAL, LoadoutReminderDB.EQUIP.BOSS, 
        LoadoutReminderOptions.EQUIP.RAIDS_PER_BOSS)

    -- #### SPECIALIZATIONS

    ---@type GGUI.Tab
    LoadoutReminder.OPTIONS.optionsPanel.specTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Specializations", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=LoadoutReminder.OPTIONS.optionsPanel.equipTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local specDropdownData = LoadoutReminder.OPTIONS:GetSpecData()

    LoadoutReminder.OPTIONS:CreateTabOptionsForType(LoadoutReminder.OPTIONS.optionsPanel.specTab, specDropdownData, false, 
        LoadoutReminderDB.SPEC.GENERAL, LoadoutReminderDB.SPEC.BOSS, 
        LoadoutReminderOptions.SPEC.RAIDS_PER_BOSS)

    LoadoutReminder.GGUI.TabSystem({LoadoutReminder.OPTIONS.optionsPanel.talentsTab, LoadoutReminder.OPTIONS.optionsPanel.addonsTab, LoadoutReminder.OPTIONS.optionsPanel.equipTab, LoadoutReminder.OPTIONS.optionsPanel.specTab})

    InterfaceOptions_AddCategory(self.optionsPanel)
end

---@param tab GGUI.Tab
---@param dropdownData GGUI.DropdownData
---@param generalSaveTable table
---@param bossSaveTable table
---@param bossToggleSaveTable table
---@param savePerSpecID boolean
function LoadoutReminder.OPTIONS:CreateTabOptionsForType(tab, dropdownData, savePerSpecID, generalSaveTable, bossSaveTable, bossToggleSaveTable)
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

    local function dropdownClickCallbackInstanceTypes(setID, setName)
        if savePerSpecID then
            local playerSpecID = GetSpecialization()
            generalSaveTable[playerSpecID][setID] = setName
        else
            generalSaveTable[setID] = setName
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
        local initialValue = (savePerSpecID and saveTable[playerSpecID][instanceType]) or saveTable[instanceType]
        ---@type GGUI.Dropdown
        tab.dropdowns.INSTANCES[instanceType] = LoadoutReminder.GGUI.Dropdown({
        parent=parent, anchorParent=parent,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=offsetX,offsetY=offsetY,label=LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType],
        initialData=dropdownData, initialValue=initialValue, initialLabel=initialValue or "-",
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
            local initialValue = (savePerSpecID and saveTable[playerSpecID][boss]) or saveTable[boss]
            ---@type GGUI.Dropdown
            tab.dropdowns.RAID_BOSSES[boss] = LoadoutReminder.GGUI.Dropdown({
            parent=parent, anchorParent=parent,
            anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=offsetX,offsetY=offsetY,label=LoadoutReminder.CONST.BOSS_NAMES[boss],
            initialData=dropdownData, initialValue=initialValue, initialLabel=initialValue or "-",
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

    local playerSpecID = GetSpecialization()

    local bySpecIDTabs = {
        TALENTS = {LoadoutReminder.OPTIONS.optionsPanel.talentsTab, LoadoutReminder.OPTIONS:GetTalentsData()}
    }
    local normalTabs = {
        ADDONS = {LoadoutReminder.OPTIONS.optionsPanel.addonsTab, LoadoutReminder.OPTIONS:GetAddonsData()},
        EQUIP = {LoadoutReminder.OPTIONS.optionsPanel.equipTab, LoadoutReminder.OPTIONS:GetEquipData()},
        SPEC = {LoadoutReminder.OPTIONS.optionsPanel.specTab, LoadoutReminder.OPTIONS:GetSpecData()}
    }
    -- instanceTypes
    for _, instanceType in pairs(LoadoutReminder.CONST.INSTANCE_TYPES) do
        for reminderType, data in pairs(bySpecIDTabs) do
            local tab = data[1]
            local dropdownData = data[2]

            if tab then
                local instanceDropdown = tab.dropdowns.INSTANCES[instanceType]
                local assignedSet = LoadoutReminderDB[reminderType].GENERAL[playerSpecID][instanceType]
                
                instanceDropdown:SetData({data=dropdownData, initialValue=assignedSet, initialLabel=assignedSet})
            end
        end

        for reminderType, data in pairs(normalTabs) do
            local tab = data[1]
            local dropdownData = data[2]

            if tab then
                local instanceDropdown = tab.dropdowns.INSTANCES[instanceType]
                local assignedSet = LoadoutReminderDB[reminderType].GENERAL[instanceType] or '-'
                
                instanceDropdown:SetData({data=dropdownData, initialValue=assignedSet, initialLabel=assignedSet})
            end
        end
    end

    -- bosses
    for boss, _ in pairs(LoadoutReminder.CONST.BOSS_NAMES) do
        for reminderType, data in pairs(bySpecIDTabs) do
            local tab = data[1]
            local dropdownData = data[2]

            if tab then
                local instanceDropdown = tab.dropdowns.RAID_BOSSES[boss]
                local assignedSet = LoadoutReminderDB[reminderType].BOSS[playerSpecID][boss]
                
                instanceDropdown:SetData({data=dropdownData, initialValue=assignedSet, initialLabel=assignedSet})
            end
        end

        for reminderType, data in pairs(normalTabs) do
            local tab = data[1]
            local dropdownData = data[2]

            if tab then
                local instanceDropdown = tab.dropdowns.RAID_BOSSES[boss]
                local assignedSet = LoadoutReminderDB[reminderType].BOSS[boss] or '-'
                
                instanceDropdown:SetData({data=dropdownData, initialValue=assignedSet, initialLabel=assignedSet})
            end
        end
    end


end
