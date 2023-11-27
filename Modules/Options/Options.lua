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
    local talentsDropdownData = {{
        label=LoadoutReminder.CONST.STARTER_BUILD,
        value=LoadoutReminder.CONST.STARTER_BUILD
    }}
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
    local addonsDropdownData = {}

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
    local equipDropdownData = {}

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
    local specDropdownData = {}

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
    local talentsTab = LoadoutReminder.GGUI.Tab({
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
    
    LoadoutReminder.OPTIONS.DROPDOWNS.TALENTS = LoadoutReminder.OPTIONS:CreateTabOptionsForType(talentsTab, talentsDropdownData, true, 
        LoadoutReminderDB.TALENTS.GENERAL, LoadoutReminderDB.TALENTS.BOSS, 
        LoadoutReminderOptions.TALENTS.RAIDS_PER_BOSS)

    -- ### ADDONS

    ---@type GGUI.Tab
    local addonsTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Addons", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=talentsTab.button.frame, adjustWidth=true,
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
        LoadoutReminder.GGUI.Text({parent=addonsTab.content, anchorParent=addonsTab.content, text="No Addon Management Addon loaded."})
    else
        

        local addonsDropdownData = LoadoutReminder.OPTIONS:GetAddonsData()

        LoadoutReminder.OPTIONS.DROPDOWNS.ADDONS = LoadoutReminder.OPTIONS:CreateTabOptionsForType(addonsTab, addonsDropdownData, false, 
        LoadoutReminderDB.ADDONS.GENERAL, LoadoutReminderDB.ADDONS.BOSS, 
        LoadoutReminderOptions.ADDONS.RAIDS_PER_BOSS)
    end

    -- #### EQUIPMENT

    ---@type GGUI.Tab
    local equipTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Equipment", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=addonsTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local equipDropdownData = LoadoutReminder.OPTIONS:GetEquipData()

    LoadoutReminder.OPTIONS.DROPDOWNS.EQUIP = LoadoutReminder.OPTIONS:CreateTabOptionsForType(equipTab, equipDropdownData, false, 
        LoadoutReminderDB.EQUIP.GENERAL, LoadoutReminderDB.EQUIP.BOSS, 
        LoadoutReminderOptions.EQUIP.RAIDS_PER_BOSS)

    -- #### SPECIALIZATIONS

    ---@type GGUI.Tab
    local specTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Specializations", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=equipTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local specDropdownData = LoadoutReminder.OPTIONS:GetSpecData()

    LoadoutReminder.OPTIONS.DROPDOWNS.SPECIALIZATIONS = LoadoutReminder.OPTIONS:CreateTabOptionsForType(specTab, specDropdownData, false, 
        LoadoutReminderDB.SPEC.GENERAL, LoadoutReminderDB.SPEC.BOSS, 
        LoadoutReminderOptions.SPEC.RAIDS_PER_BOSS)

    LoadoutReminder.GGUI.TabSystem({talentsTab, addonsTab, equipTab, specTab})

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
    local generalTab = LoadoutReminder.GGUI.Tab({
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
    local raidsTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Raids", parent=tab.content, anchorParent=generalTab.button.frame, adjustWidth=true,
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

    -- Row 1

    local initialValueDUNGEON = (savePerSpecID and generalSaveTable[playerSpecID].DUNGEON) or generalSaveTable.DUNGEON

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX,offsetY=generalDropdownBaseOffsetY,label="Dungeon",
        initialData=dropdownData, initialValue=initialValueDUNGEON, initialLabel=initialValueDUNGEON or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackInstanceTypes("DUNGEON", label)
        end,
    }))

    local initialValueRAID = (savePerSpecID and generalSaveTable[playerSpecID].RAID) or generalSaveTable.RAID
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX,offsetY=generalDropdownBaseOffsetY,label="Raid",
        initialData=dropdownData, initialValue=initialValueRAID, initialLabel=initialValueRAID or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackInstanceTypes("RAID", label)
        end,
    }))
    local initialValueARENA = (savePerSpecID and generalSaveTable[playerSpecID].ARENA) or generalSaveTable.ARENA
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX*2,offsetY=generalDropdownBaseOffsetY,label="Arena",
        initialData=dropdownData, initialValue=initialValueARENA, initialLabel=initialValueARENA or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackInstanceTypes("ARENA", label)
        end,
    }))

    -- Row 2
    local initialValueBG = (savePerSpecID and generalSaveTable[playerSpecID].BG) or generalSaveTable.BG
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX,offsetY=generalDropdownBaseOffsetY+generalDropdownSpacingY,label="Battlegrounds",
        initialData=dropdownData, initialValue=initialValueBG, initialLabel=initialValueBG or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackInstanceTypes("BG", label)
        end,
    }))
    local initialValueOPENWORLD = (savePerSpecID and generalSaveTable[playerSpecID].OPENWORLD) or generalSaveTable.OPENWORLD
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX,offsetY=generalDropdownBaseOffsetY+generalDropdownSpacingY,label="Open World",
        initialData=dropdownData, initialValue=initialValueOPENWORLD, initialLabel=initialValueOPENWORLD or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackInstanceTypes("OPENWORLD", label)
        end,
    }))

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

    ---@type GGUI.Tab
    raidsTab.content.amirdrassilTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Amirdrassil", parent=raidsTab.content, anchorParent=generalTab.button.frame, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=0,offsetY=-40
        },
        canBeEnabled=true,
        parent=raidsTab.content,
        anchorParent=raidsTab.content,
        anchorA="TOP", anchorB="TOP", offsetX=0,offsetY=-40,
        sizeX=subTabContentX, sizeY=subTabContentY,
    })

    local amirdrassilTab = raidsTab.content.amirdrassilTab

    local bossDropdownSpacingX = 200
    local bossDropdownSpacingY = 20
    local bossDropdownBaseOffsetX = -20
    local bossDropdownBaseOffsetY = -80

    LoadoutReminder.GGUI.Checkbox({label='Per Boss', parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
    anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=-10, initialValue=bossToggleSaveTable[LoadoutReminder.CONST.RAIDS.AMIRDRASSIL] ,clickCallback=function (_, checked)
        bossToggleSaveTable[LoadoutReminder.CONST.RAIDS.AMIRDRASSIL] = checked
        -- TODO: maybe disable/hide dropdowns if not checked
    end})

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_GNARLROOT,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_GNARLROOT, initialLabel=bossSaveTable.AMIRDRASSIL_GNARLROOT or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_GNARLROOT", label)
        end,
    }))

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_IGIRA,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_IGIRA, initialLabel=bossSaveTable.AMIRDRASSIL_IGIRA or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_IGIRA", label)
        end,
    }))

    -- Row 1

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_VOLCOROSS,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_VOLCOROSS, initialLabel=bossSaveTable.AMIRDRASSIL_VOLCOROSS or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_VOLCOROSS", label)
        end,
    }))

    -- Row 2

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_COUNCIL_OF_DREAMS,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_COUNCIL_OF_DREAMS, initialLabel=bossSaveTable.AMIRDRASSIL_COUNCIL_OF_DREAMS or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_COUNCIL_OF_DREAMS", label)
        end,
    }))

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_LARODAR,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_LARODAR, initialLabel=bossSaveTable.AMIRDRASSIL_LARODAR or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_LARODAR", label)
        end,
    }))


    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_NYMUE,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_NYMUE, initialLabel=bossSaveTable.AMIRDRASSIL_NYMUE or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_NYMUE", label)
        end,
    }))

    -- Row 3

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_SMOLDERON,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_SMOLDERON, initialLabel=bossSaveTable.AMIRDRASSIL_SMOLDERON or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_SMOLDERON", label)
        end,
    }))

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_TINDRAL_SAGESWIFT,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_TINDRAL_SAGESWIFT, initialLabel=bossSaveTable.AMIRDRASSIL_TINDRAL_SAGESWIFT or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_TINDRAL_SAGESWIFT", label)
        end,
    }))


    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_FYRAKK,
        initialData=dropdownData, initialValue=bossSaveTable.AMIRDRASSIL_FYRAKK, initialLabel=bossSaveTable.AMIRDRASSIL_FYRAKK or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("AMIRDRASSIL_FYRAKK", label)
        end,
    }))

    ---@type GGUI.Tab
    raidsTab.content.aberrusTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Aberrus", parent=raidsTab.content, anchorParent=amirdrassilTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,offsetY=0
        },
        canBeEnabled=true,
        parent=raidsTab.content,
        anchorParent=raidsTab.content,
        anchorA="TOP", anchorB="TOP", offsetX=0,offsetY=20,
        sizeX=subTabContentX, sizeY=subTabContentY,
    })

    local aberrusTab = raidsTab.content.aberrusTab

    LoadoutReminder.GGUI.Checkbox({label='Talents per Boss', parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
    anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=-10, initialValue=LoadoutReminderOptions.TALENTS.RAIDS_PER_BOSS[LoadoutReminder.CONST.RAIDS.ABERRUS], clickCallback=function (_, checked)
        LoadoutReminderOptions.TALENTS.RAIDS_PER_BOSS[LoadoutReminder.CONST.RAIDS.ABERRUS] = checked
        -- TODO: maybe disable/hide dropdowns if not checked
    end})

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_KAZZARA,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_KAZZARA, initialLabel=bossSaveTable.ABERRUS_KAZZARA or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_KAZZARA", label)
        end,
    }))

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_AMALGAMATION_CHAMBER,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_AMALGAMATION_CHAMBER, initialLabel=bossSaveTable.ABERRUS_AMALGAMATION_CHAMBER or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_AMALGAMATION_CHAMBER", label)
        end,
    }))

    -- Row 1

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_FORGOTTEN_EXPERIMENTS,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_FORGOTTEN_EXPERIMENTS, initialLabel=bossSaveTable.ABERRUS_FORGOTTEN_EXPERIMENTS or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_FORGOTTEN_EXPERIMENTS", label)
        end,
    }))

    -- Row 2

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_ASSAULT,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_ASSAULT, initialLabel=bossSaveTable.ABERRUS_ASSAULT or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_ASSAULT", label)
        end,
    }))

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_RASHOK,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_RASHOK, initialLabel=bossSaveTable.ABERRUS_RASHOK or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_RASHOK", label)
        end,
    }))


    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_ZSKARN,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_ZSKARN, initialLabel=bossSaveTable.ABERRUS_ZSKARN or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_ZSKARN", label)
        end,
    }))

    -- Row 3

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_MAGMORAX,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_MAGMORAX, initialLabel=bossSaveTable.ABERRUS_MAGMORAX or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_MAGMORAX", label)
        end,
    }))

    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_ECHO,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_ECHO, initialLabel=bossSaveTable.ABERRUS_ECHO or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_ECHO", label)
        end,
    }))


    ---@type GGUI.Dropdown
    table.insert(dropdowns, LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_SARKARETH,
        initialData=dropdownData, initialValue=bossSaveTable.ABERRUS_SARKARETH, initialLabel=bossSaveTable.ABERRUS_SARKARETH or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackBosses("ABERRUS_SARKARETH", label)
        end,
    }))
    
    LoadoutReminder.GGUI.TabSystem({amirdrassilTab, aberrusTab})
    LoadoutReminder.GGUI.TabSystem({generalTab, raidsTab})

    return dropdowns
end

function LoadoutReminder.OPTIONS:ResetDropdowns()
    for _, dropdown in pairs(LoadoutReminder.OPTIONS.DROPDOWNS.TALENTS) do
        -- TODO
    end
end
