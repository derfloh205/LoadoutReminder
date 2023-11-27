_, LoadoutReminder = ...

LoadoutReminder.OPTIONS = {}
function LoadoutReminder.OPTIONS:Init()
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

    -- #### TALENTS

    local typeTabContentX=500
    local typeTabContentY=500

    ---@type GGUI.Tab
    local generalTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="General", parent=talentsTab.content, anchorParent=talentsTab.button.frame, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetX=0,offsetY=-20
        },
        canBeEnabled=true,
        parent=talentsTab.content,
        anchorParent=talentsTab.content,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=typeTabContentX, sizeY=typeTabContentY,
    })
    ---@type GGUI.Tab
    local raidsTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Raids", parent=talentsTab.content, anchorParent=generalTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=talentsTab.content,
        anchorParent=talentsTab.content,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=typeTabContentX, sizeY=typeTabContentY,
    })

    local talentSets = LoadoutReminder.TALENTS:GetTalentSets()

    -- convert to dropdown data, always include starter build label
    local dropdownData = {{
        label=LoadoutReminder.CONST.STARTER_BUILD,
        value=LoadoutReminder.CONST.STARTER_BUILD
    }}
    table.foreach(talentSets, function(_, configInfo)
        table.insert(dropdownData, {
            label=configInfo.name,
            value=configInfo.name,
        })
    end)

    local function dropdownClickCallbackTalents(setID, setName)
        -- To save per spec
        local playerSpecID = GetSpecialization()
        LoadoutReminderDB.TALENTS.GENERAL[playerSpecID][setID] = setName
        -- a new set was chosen for a new environment
        -- update visibility
        LoadoutReminder.MAIN:CheckInstanceTypes()
    end

    local generalDropdownSpacingX = 200
    local generalDropdownSpacingY = -60
    local generalDropdownBaseOffsetX = -80
    local generalDropdownBaseOffsetY = -80

    -- Row 1

    local playerSpecID = GetSpecialization()

    ---@type GGUI.Dropdown
    generalTab.content.dungeonDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX,offsetY=generalDropdownBaseOffsetY,label="Dungeon",
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].DUNGEON, initialLabel=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].DUNGEON or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackTalents("DUNGEON", label)
        end,
    })
    generalTab.content.raidDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX,offsetY=generalDropdownBaseOffsetY,label="Raid",
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].RAID, initialLabel=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].RAID or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackTalents("RAID", label)
        end,
    })
    generalTab.content.arenaDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX*2,offsetY=generalDropdownBaseOffsetY,label="Arena",
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].ARENA, initialLabel=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].ARENA or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackTalents("ARENA", label)
        end,
    })

    -- Row 2
    generalTab.content.battlegroundsDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX,offsetY=generalDropdownBaseOffsetY+generalDropdownSpacingY,label="Battlegrounds",
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].BG, initialLabel=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].BG or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackTalents("BG", label)
        end,
    })
    generalTab.content.openWorldDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX,offsetY=generalDropdownBaseOffsetY+generalDropdownSpacingY,label="Open World",
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].OPENWORLD, initialLabel=LoadoutReminderDB.TALENTS.GENERAL[playerSpecID].OPENWORLD or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackTalents("OPENWORLD", label)
        end,
    })

    local subTabContentX = 400
    local subTabContentY = 400

    local function bossDropdownClickCallbackTalents(setID, setName)
        LoadoutReminderDB.TALENTS.BOSS[setID] = setName
        -- a new set was chosen for a new boss
        -- update visibility
        LoadoutReminder.MAIN:CheckTargetForBoss()
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

    LoadoutReminder.GGUI.Checkbox({label='Talents per Boss', parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
    anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=-10, initialValue=LoadoutReminderOptions.TALENTS.RAIDS_PER_BOSS[LoadoutReminder.CONST.RAIDS.AMIRDRASSIL] ,clickCallback=function (_, checked)
        LoadoutReminderOptions.TALENTS.RAIDS_PER_BOSS[LoadoutReminder.CONST.RAIDS.AMIRDRASSIL] = checked
        -- TODO: maybe disable/hide dropdowns if not checked
    end})

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_GNARLROOT,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_GNARLROOT, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_GNARLROOT or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_GNARLROOT", label)
        end,
    })

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_IGIRA,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_IGIRA, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_IGIRA or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_IGIRA", label)
        end,
    })

    -- Row 1

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_VOLCOROSS,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_VOLCOROSS, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_VOLCOROSS or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_VOLCOROSS", label)
        end,
    })

    -- Row 2

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_COUNCIL_OF_DREAMS,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_COUNCIL_OF_DREAMS, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_COUNCIL_OF_DREAMS or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_COUNCIL_OF_DREAMS", label)
        end,
    })

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_LARODAR,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_LARODAR, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_LARODAR or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_LARODAR", label)
        end,
    })


    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_NYMUE,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_NYMUE, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_NYMUE or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_NYMUE", label)
        end,
    })

    -- Row 3

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_SMOLDERON,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_SMOLDERON, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_SMOLDERON or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_SMOLDERON", label)
        end,
    })

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_TINDRAL_SAGESWIFT,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_TINDRAL_SAGESWIFT, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_TINDRAL_SAGESWIFT or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_TINDRAL_SAGESWIFT", label)
        end,
    })


    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_FYRAKK,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_FYRAKK, initialLabel=LoadoutReminderDB.TALENTS.BOSS.AMIRDRASSIL_FYRAKK or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("AMIRDRASSIL_FYRAKK", label)
        end,
    })

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
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_KAZZARA,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_KAZZARA, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_KAZZARA or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_KAZZARA", label)
        end,
    })

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_AMALGAMATION_CHAMBER,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_AMALGAMATION_CHAMBER, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_AMALGAMATION_CHAMBER or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_AMALGAMATION_CHAMBER", label)
        end,
    })

    -- Row 1

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_FORGOTTEN_EXPERIMENTS,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_FORGOTTEN_EXPERIMENTS, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_FORGOTTEN_EXPERIMENTS or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_FORGOTTEN_EXPERIMENTS", label)
        end,
    })

    -- Row 2

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_ASSAULT,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_ASSAULT, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_ASSAULT or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_ASSAULT", label)
        end,
    })

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_RASHOK,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_RASHOK, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_RASHOK or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_RASHOK", label)
        end,
    })


    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_ZSKARN,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_ZSKARN, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_ZSKARN or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_ZSKARN", label)
        end,
    })

    -- Row 3

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_MAGMORAX,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_MAGMORAX, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_MAGMORAX or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_MAGMORAX", label)
        end,
    })

    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_ECHO,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_ECHO, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_ECHO or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_ECHO", label)
        end,
    })


    ---@type GGUI.Dropdown
    LoadoutReminder.GGUI.Dropdown({
        parent=aberrusTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.ABERRUS_SARKARETH,
        initialData=dropdownData, initialValue=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_SARKARETH, initialLabel=LoadoutReminderDB.TALENTS.BOSS.ABERRUS_SARKARETH or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallbackTalents("ABERRUS_SARKARETH", label)
        end,
    })

    
    LoadoutReminder.GGUI.TabSystem({amirdrassilTab, aberrusTab})

    LoadoutReminder.GGUI.TabSystem({generalTab, raidsTab})

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

     -- Only continue if any optional dependency is loaded, otherwise show text
     if not LoadoutReminder.ADDONS:Init() then
        LoadoutReminder.GGUI.Text({parent=addonsTab.content, anchorParent=addonsTab.content, text="No Addon Management Addon loaded."})
        return
    end

    ---@type GGUI.Tab
    local generalTabAddons = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="General", parent=addonsTab.content, anchorParent=talentsTab.button.frame, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetX=0,offsetY=-20
        },
        canBeEnabled=true,
        parent=addonsTab.content,
        anchorParent=addonsTab.content,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=typeTabContentX, sizeY=typeTabContentY,
    })

    generalTabAddons.button:SetEnabled(false)

    -- TODO: Check if an addonset dependency is even loaded! Otherwise dont init
    local addonSets = LoadoutReminder.ADDONS:GetAddonSets()

    -- convert to dropdown data, always include starter build label
    local dropdownDataAddons = {}

    table.foreach(addonSets, function(setName, _)
        table.insert(dropdownDataAddons, {
            label=setName,
            value=setName,
        })
    end)

    local function dropdownClickCallbackAddons(setID, setName)
        LoadoutReminderDB.ADDONS.GENERAL[setID] = setName
        -- a new set was chosen for a new environment
        -- update visibility
        LoadoutReminder.MAIN:CheckInstanceTypes()
    end

    local generalDropdownSpacingX = 200
    local generalDropdownSpacingY = -60
    local generalDropdownBaseOffsetX = -80
    local generalDropdownBaseOffsetY = -80

    -- Row 1

    ---@type GGUI.Dropdown
    generalTabAddons.content.dungeonDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTabAddons.content, anchorParent=generalTabAddons.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX,offsetY=generalDropdownBaseOffsetY,label="Dungeon",
        initialData=dropdownDataAddons, initialValue=LoadoutReminderDB.ADDONS.GENERAL.DUNGEON, initialLabel=LoadoutReminderDB.ADDONS.GENERAL.DUNGEON or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackAddons("DUNGEON", label)
        end,
    })
    generalTabAddons.content.raidDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTabAddons.content, anchorParent=generalTabAddons.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX,offsetY=generalDropdownBaseOffsetY,label="Raid",
        initialData=dropdownDataAddons, initialValue=LoadoutReminderDB.ADDONS.GENERAL.RAID, initialLabel=LoadoutReminderDB.ADDONS.GENERAL.RAID or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackAddons("RAID", label)
        end,
    })
    generalTabAddons.content.arenaDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTabAddons.content, anchorParent=generalTabAddons.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX*2,offsetY=generalDropdownBaseOffsetY,label="Arena",
        initialData=dropdownDataAddons, initialValue=LoadoutReminderDB.ADDONS.GENERAL.ARENA, initialLabel=LoadoutReminderDB.ADDONS.GENERAL.ARENA or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackAddons("ARENA", label)
        end,
    })

    -- Row 2
    generalTabAddons.content.battlegroundsDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTabAddons.content, anchorParent=generalTabAddons.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX,offsetY=generalDropdownBaseOffsetY+generalDropdownSpacingY,label="Battlegrounds",
        initialData=dropdownDataAddons, initialValue=LoadoutReminderDB.ADDONS.GENERAL.BG, initialLabel=LoadoutReminderDB.ADDONS.GENERAL.BG or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackAddons("BG", label)
        end,
    })
    generalTabAddons.content.openWorldDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTabAddons.content, anchorParent=generalTabAddons.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=generalDropdownBaseOffsetX+generalDropdownSpacingX,offsetY=generalDropdownBaseOffsetY+generalDropdownSpacingY,label="Open World",
        initialData=dropdownDataAddons, initialValue=LoadoutReminderDB.ADDONS.GENERAL.OPENWORLD, initialLabel=LoadoutReminderDB.ADDONS.GENERAL.OPENWORLD or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallbackAddons("OPENWORLD", label)
        end,
    })



    LoadoutReminder.GGUI.TabSystem({talentsTab, addonsTab})

	InterfaceOptions_AddCategory(self.optionsPanel)
end