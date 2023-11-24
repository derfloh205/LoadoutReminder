_, LoadoutReminder = ...

LoadoutReminder.OPTIONS = {}
function LoadoutReminder.OPTIONS:Init()
    LoadoutReminder.OPTIONS.optionsPanel = CreateFrame("Frame", "LoadoutReminderOptionsPanel")

	LoadoutReminder.OPTIONS.optionsPanel:HookScript("OnShow", function(self)
		end)
        LoadoutReminder.OPTIONS.optionsPanel.name = "Loadout Reminder: Talents"
	local title = LoadoutReminder.OPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("Talent Loadout Reminder Options")

    local tabContentX=500
    local tabContentY=500

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
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })
    ---@type GGUI.Tab
    local raidBossesTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Raid Bosses", parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=generalTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=LoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local raidBossHelpIcon = LoadoutReminder.GGUI.HelpIcon({
        parent=LoadoutReminder.OPTIONS.optionsPanel, anchorParent=raidBossesTab.button.frame, offsetX=0, offsetY=5,
        text="Work in Progress", anchorA="BOTTOM", anchorB="TOP"
    })

    local talentSets = LoadoutReminder.MAIN:GetTalentSets()

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

    local function dropdownClickCallback(setID, setName)
        LoadoutReminderDB[setID] = setName
        -- a new set was chosen for a new environment
        -- update visibility
        LoadoutReminder.MAIN:CheckAndShowReload()
    end

    ---@type GGUI.Dropdown
    generalTab.content.dungeonDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-20,label="Dungeon",
        initialData=dropdownData, initialValue=LoadoutReminderDB.DUNGEON, initialLabel=LoadoutReminderDB.DUNGEON or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("DUNGEON", label)
        end,
    })
    generalTab.content.raidDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=220,offsetY=-20,label="Raid",
        initialData=dropdownData, initialValue=LoadoutReminderDB.RAID, initialLabel=LoadoutReminderDB.RAID or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("RAID", label)
        end,
    })
    generalTab.content.arenaDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-60,label="Arena",
        initialData=dropdownData, initialValue=LoadoutReminderDB.ARENA, initialLabel=LoadoutReminderDB.ARENA or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("ARENA", label)
        end,
    })
    generalTab.content.battlegroundsDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=220,offsetY=-60,label="Battlegrounds",
        initialData=dropdownData, initialValue=LoadoutReminderDB.BG, initialLabel=LoadoutReminderDB.BG or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("BG", label)
        end,
    })
    generalTab.content.openWorldDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-100,label="Open World",
        initialData=dropdownData, initialValue=LoadoutReminderDB.OPENWORLD, initialLabel=LoadoutReminderDB.OPENWORLD or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("OPENWORLD", label)
        end,
    })

    local subTabContentX = 400
    local subTabContentY = 400

    local function bossDropdownClickCallback(setID, setName)
        LoadoutReminderBossDB[setID] = setName
        -- a new set was chosen for a new boss
        -- update visibility
        LoadoutReminder.MAIN:CheckAndShowNewTarget()
    end

    ---@type GGUI.Tab
    raidBossesTab.content.amirdrassilTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Amirdrassil", parent=raidBossesTab.content, anchorParent=generalTab.button.frame, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=0,offsetY=-40
        },
        canBeEnabled=true,
        parent=raidBossesTab.content,
        anchorParent=raidBossesTab.content,
        anchorA="TOP", anchorB="TOP", offsetX=0,offsetY=-40,
        sizeX=subTabContentX, sizeY=subTabContentY,
    })

    local amirdrassilTab = raidBossesTab.content.amirdrassilTab

    local bossDropdownSpacingX = 200
    local bossDropdownSpacingY = 20
    local bossDropdownBaseOffsetX = -20
    local bossDropdownBaseOffsetY = -60

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilGnarlrootDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_GNARLROOT,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_GNARLROOT, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_GNARLROOT or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_GNARLROOT", label)
        end,
    })

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilIgiraDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_IGIRA,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_IGIRA, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_IGIRA or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_IGIRA", label)
        end,
    })

    -- Row 1

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilVolcorossDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_VOLCOROSS,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_VOLCOROSS, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_VOLCOROSS or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_VOLCOROSS", label)
        end,
    })

    -- Row 2

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilCOUNCIL_OF_DREAMSDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_COUNCIL_OF_DREAMS,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_COUNCIL_OF_DREAMS, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_COUNCIL_OF_DREAMS or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_COUNCIL_OF_DREAMS", label)
        end,
    })

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilLARODARDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_LARODAR,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_LARODAR, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_LARODAR or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_LARODAR", label)
        end,
    })


    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilNYMUEDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*2,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_NYMUE,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_NYMUE, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_NYMUE or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_NYMUE", label)
        end,
    })

    -- Row 3

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilSMOLDERONDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_SMOLDERON,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_SMOLDERON, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_SMOLDERON or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_SMOLDERON", label)
        end,
    })

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilTINDRAL_SAGESWIFTDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_TINDRAL_SAGESWIFT,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_TINDRAL_SAGESWIFT, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_TINDRAL_SAGESWIFT or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_TINDRAL_SAGESWIFT", label)
        end,
    })


    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilFYRAKKDropdown=LoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*3,label=LoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_FYRAKK,
        initialData=dropdownData, initialValue=LoadoutReminderBossDB.AMIRDRASSIL_FYRAKK, initialLabel=LoadoutReminderBossDB.AMIRDRASSIL_FYRAKK or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_FYRAKK", label)
        end,
    })

    ---@type GGUI.Tab
    raidBossesTab.content.aberrusTab = LoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Aberrus", parent=raidBossesTab.content, anchorParent=amirdrassilTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,offsetY=0
        },
        canBeEnabled=true,
        parent=raidBossesTab.content,
        anchorParent=raidBossesTab.content,
        anchorA="TOP", anchorB="TOP", offsetX=0,offsetY=20,
        sizeX=subTabContentX, sizeY=subTabContentY,
    })

    local aberrusTab = raidBossesTab.content.aberrusTab

    LoadoutReminder.GGUI.TabSystem({amirdrassilTab, aberrusTab})

    LoadoutReminder.GGUI.TabSystem({generalTab, raidBossesTab})

	InterfaceOptions_AddCategory(self.optionsPanel)
end