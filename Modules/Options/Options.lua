_, TalentLoadoutReminder = ...

TalentLoadoutReminder.OPTIONS = {}
function TalentLoadoutReminder.OPTIONS:Init()
    TalentLoadoutReminder.OPTIONS.optionsPanel = CreateFrame("Frame", "TalentLoadoutReminderOptionsPanel")

	TalentLoadoutReminder.OPTIONS.optionsPanel:HookScript("OnShow", function(self)
		end)
        TalentLoadoutReminder.OPTIONS.optionsPanel.name = "Loadout Reminder: Talents"
	local title = TalentLoadoutReminder.OPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("Talent Loadout Reminder Options")

    local tabContentX=500
    local tabContentY=500

    ---@type GGUI.Tab
    local generalTab = TalentLoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="General", parent=TalentLoadoutReminder.OPTIONS.optionsPanel, anchorParent=TalentLoadoutReminder.OPTIONS.optionsPanel, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=20,offsetY=-20
        },
        canBeEnabled=true,
        parent=TalentLoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=TalentLoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })
    ---@type GGUI.Tab
    local raidBossesTab = TalentLoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Raid Bosses", parent=TalentLoadoutReminder.OPTIONS.optionsPanel, anchorParent=generalTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=TalentLoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=TalentLoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local raidBossHelpIcon = TalentLoadoutReminder.GGUI.HelpIcon({
        parent=TalentLoadoutReminder.OPTIONS.optionsPanel, anchorParent=raidBossesTab.button.frame, offsetX=0, offsetY=5,
        text="Work in Progress", anchorA="BOTTOM", anchorB="TOP"
    })

    local talentSets = TalentLoadoutReminder.MAIN:GetTalentSets()

    -- convert to dropdown data, always include starter build label
    local dropdownData = {{
        label=TalentLoadoutReminder.CONST.STARTER_BUILD,
        value=TalentLoadoutReminder.CONST.STARTER_BUILD
    }}
    table.foreach(talentSets, function(_, configInfo)
        table.insert(dropdownData, {
            label=configInfo.name,
            value=configInfo.name,
        })
    end)

    local function dropdownClickCallback(setID, setName)
        TalentLoadoutReminderDB[setID] = setName
        -- a new set was chosen for a new environment
        -- update visibility
        TalentLoadoutReminder.MAIN:CheckAndShowReload()
    end

    ---@type GGUI.Dropdown
    generalTab.content.dungeonDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-20,label="Dungeon",
        initialData=dropdownData, initialValue=TalentLoadoutReminderDB.DUNGEON, initialLabel=TalentLoadoutReminderDB.DUNGEON or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("DUNGEON", label)
        end,
    })
    generalTab.content.raidDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=220,offsetY=-20,label="Raid",
        initialData=dropdownData, initialValue=TalentLoadoutReminderDB.RAID, initialLabel=TalentLoadoutReminderDB.RAID or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("RAID", label)
        end,
    })
    generalTab.content.arenaDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-60,label="Arena",
        initialData=dropdownData, initialValue=TalentLoadoutReminderDB.ARENA, initialLabel=TalentLoadoutReminderDB.ARENA or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("ARENA", label)
        end,
    })
    generalTab.content.battlegroundsDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=220,offsetY=-60,label="Battlegrounds",
        initialData=dropdownData, initialValue=TalentLoadoutReminderDB.BG, initialLabel=TalentLoadoutReminderDB.BG or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("BG", label)
        end,
    })
    generalTab.content.openWorldDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-100,label="Open World",
        initialData=dropdownData, initialValue=TalentLoadoutReminderDB.OPENWORLD, initialLabel=TalentLoadoutReminderDB.OPENWORLD or "Not set yet",
        clickCallback=function (self, label, _)
            dropdownClickCallback("OPENWORLD", label)
        end,
    })

    local subTabContentX = 400
    local subTabContentY = 400

    local function bossDropdownClickCallback(setID, setName)
        TalentLoadoutReminderBossDB[setID] = setName
        -- a new set was chosen for a new boss
        -- update visibility
        TalentLoadoutReminder.MAIN:CheckAndShowNewTarget()
    end

    ---@type GGUI.Tab
    raidBossesTab.content.amirdrassilTab = TalentLoadoutReminder.GGUI.Tab({
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
    generalTab.content.amirdrassilGnarlrootDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_GNARLROOT,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_GNARLROOT, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_GNARLROOT or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_GNARLROOT", label)
        end,
    })

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilIgiraDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_IGIRA,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_IGIRA, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_IGIRA or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_IGIRA", label)
        end,
    })

    -- Row 1

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilVolcorossDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_VOLCOROSS,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_VOLCOROSS, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_VOLCOROSS or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_VOLCOROSS", label)
        end,
    })

    -- Row 2

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilCOUNCIL_OF_DREAMSDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*2,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_COUNCIL_OF_DREAMS,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_COUNCIL_OF_DREAMS, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_COUNCIL_OF_DREAMS or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_COUNCIL_OF_DREAMS", label)
        end,
    })

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilLARODARDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*2,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_LARODAR,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_LARODAR, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_LARODAR or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_LARODAR", label)
        end,
    })


    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilNYMUEDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*2,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_NYMUE,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_NYMUE, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_NYMUE or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_NYMUE", label)
        end,
    })

    -- Row 3

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilSMOLDERONDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX,offsetY=bossDropdownBaseOffsetY*3,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_SMOLDERON,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_SMOLDERON, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_SMOLDERON or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_SMOLDERON", label)
        end,
    })

    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilTINDRAL_SAGESWIFTDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX,offsetY=bossDropdownBaseOffsetY*3,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_TINDRAL_SAGESWIFT,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_TINDRAL_SAGESWIFT, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_TINDRAL_SAGESWIFT or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_TINDRAL_SAGESWIFT", label)
        end,
    })


    ---@type GGUI.Dropdown
    generalTab.content.amirdrassilFYRAKKDropdown=TalentLoadoutReminder.GGUI.Dropdown({
        parent=amirdrassilTab.content, anchorParent=amirdrassilTab.button.frame,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=bossDropdownBaseOffsetX + bossDropdownSpacingX*2,offsetY=bossDropdownBaseOffsetY*3,label=TalentLoadoutReminder.CONST.BOSS_NAMES.AMIRDRASSIL_FYRAKK,
        initialData=dropdownData, initialValue=TalentLoadoutReminderBossDB.AMIRDRASSIL_FYRAKK, initialLabel=TalentLoadoutReminderBossDB.AMIRDRASSIL_FYRAKK or "Not set yet",
        clickCallback=function (self, label, _)
            bossDropdownClickCallback("AMIRDRASSIL_FYRAKK", label)
        end,
    })

    ---@type GGUI.Tab
    raidBossesTab.content.aberrusTab = TalentLoadoutReminder.GGUI.Tab({
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

    TalentLoadoutReminder.GGUI.TabSystem({amirdrassilTab, aberrusTab})

    TalentLoadoutReminder.GGUI.TabSystem({generalTab, raidBossesTab})

	InterfaceOptions_AddCategory(self.optionsPanel)
end