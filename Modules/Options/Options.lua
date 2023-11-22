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
        TalentLoadoutReminder.MAIN:CheckAndShow()
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

    raidBossesTab.content.comingSoonText = TalentLoadoutReminder.GGUI.Text({
        parent=raidBossesTab.content, anchorParent=raidBossesTab.content,
        text="Coming Soon!"
    })

    TalentLoadoutReminder.GGUI.TabSystem({generalTab, raidBossesTab})

	InterfaceOptions_AddCategory(self.optionsPanel)
end