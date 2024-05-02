---@class LoadoutReminder
local LoadoutReminder = select(2, ...)
local LoadoutReminderAddonName = select(1, ...)

local GGUI = LoadoutReminder.GGUI
local GUTIL = LoadoutReminder.GUTIL
local f = GUTIL:GetFormatter()


---@class LoadoutReminder.INIT : Frame
LoadoutReminder.INIT = GUTIL:CreateRegistreeForEvents({ "ADDON_LOADED" })

LoadoutReminder.INIT.FRAMES = {}
LoadoutReminder.INIT.READY = false

function LoadoutReminder.INIT:Init()
	if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
		-- poll until info is available
		C_Timer.After(LoadoutReminder.CONST.INIT_POLL_INTERVAL, LoadoutReminder.INIT.Init)
		return
	end
	LoadoutReminder.INIT:InitOptionsPanel()
	LoadoutReminder.DB:Init()
	LoadoutReminder.GGUI:InitializePopup({
		title = "LoadoutReminder",
		backdropOptions = LoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS,
		frameID = LoadoutReminder.CONST.FRAMES.POPUP,
		sizeX = 150,
		sizeY = 100,
	})
	LoadoutReminder.NEWS:Init()
	LoadoutReminder.ADDONS:Init()
	LoadoutReminder.INIT:InitializeSlashCommands()
	LoadoutReminder.OPTIONS.FRAMES:Init()
	LoadoutReminder.REMINDER_FRAME.FRAMES:Init()
	LoadoutReminder.INIT:InitializeMinimapButton()

	-- restore frame positions
	local reminderFrame = LoadoutReminder.REMINDER_FRAME.frame
	reminderFrame:RestoreSavedConfig(UIParent)
	local newsFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.INIT.FRAMES, LoadoutReminder.CONST.FRAMES.NEWS)
	if newsFrame then
		newsFrame:RestoreSavedConfig(UIParent)
	end

	-- everything initalized
	LoadoutReminder.INIT.READY = true

	-- Make first check after everything is loaded
	LoadoutReminder.CHECK:CheckSituations()

	-- show news
	LoadoutReminder.NEWS:ShowNews()
end

function LoadoutReminder.INIT:InitOptionsPanel()
	local optionsPanel = CreateFrame("Frame")
	optionsPanel.name = "LoadoutReminder"
	optionsPanel.hint = GGUI.Text {
		parent = optionsPanel, anchorPoints = { { anchorParent = optionsPanel } },
		text = f.white("Use " .. f.whisper("/lor config") .. " to configure " .. f.l("LoadoutReminder"))
	}
	InterfaceOptions_AddCategory(optionsPanel)
end

function LoadoutReminder.INIT:InitializeSlashCommands()
	SLASH_LOADOUTREMINDER1 = "/loadoutreminder"
	SLASH_LOADOUTREMINDER2 = "/lor"
	SlashCmdList["LOADOUTREMINDER"] = function(input)
		input = SecureCmdOptionParse(input)
		if not input then return end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if command == "resetdb" then
			LoadoutReminderDB = nil
			C_UI.Reload()
		end

		if command == "config" then
			LoadoutReminder.OPTIONS.frame:Show()
		end

		if command == "check" then
			LoadoutReminder.CHECK.sessionPause = false
			LoadoutReminder.CHECK:CheckSituations()
		end

		if command == "news" then
			LoadoutReminder.NEWS:ShowNews(true)
		end

		if command == "npc" then
			local npcID = LoadoutReminder.UTIL:GetTargetNPCID()
			if npcID then
				print(GUTIL:ColorizeText("/lor npc", GUTIL.COLORS.BRIGHT_BLUE))
				print("NPC: " .. select(1, UnitName("target")))
				print("- id: " .. npcID)
			end
		end

		if command == "instance" then
			local raid = LoadoutReminder.UTIL:GetCurrentRaid()
			local instance = LoadoutReminder.UTIL:GetCurrentInstanceType()
			local difficulty = LoadoutReminder.UTIL:GetInstanceDifficulty()
			print(GUTIL:ColorizeText("/lor instance", GUTIL.COLORS.BRIGHT_BLUE))
			print("InstanceType: " .. tostring(instance))
			print("IsInInstance: " .. tostring(IsInInstance()))
			print("- id: " .. tostring(select(8, GetInstanceInfo())))
			print("- Raid: " .. tostring(raid))
			print("Difficulty: " .. tostring(difficulty))
			print("- id: " .. tostring(select(3, GetInstanceInfo())))
		end

		if command == "" then
			print("LoadoutReminder Help")
			print("/lor or /loadoutreminder can be used for following commands")
			print("/lor -> show help text")
			print("/lor news -> show last update news")
			print("/lor config -> show options panel")
			print("/lor check -> if configured check current player situation and reset session pause")
			print("/lor npc -> show npc id for target (useful for developer)")
			print("/lor instance -> show instance info (useful for developer)")
		end
	end
end

function LoadoutReminder.INIT:InitializeMinimapButton()
	local LibIcon = LibStub("LibDBIcon-1.0")
	local libDB = LibStub("LibDataBroker-1.1")
	local ldb = libDB:NewDataObject("LoadoutReminder", {
		type = "data source",
		label = "LoadoutReminder",
		tocname = "LoadoutReminder",
		icon = "Interface\\Icons\\INV_Misc_Bell_01",
		OnClick = function()
			LoadoutReminder.OPTIONS.frame:Show()
		end,
	})

	function ldb.OnTooltipShow(tt)
		tt:AddLine("LoadoutReminder\n")
		tt:AddLine(GUTIL:ColorizeText("Click to Configure!", GUTIL.COLORS.WHITE))
	end

	LibIcon:Register("LoadoutReminder", ldb, LoadoutReminder.DB.OPTIONS:Get("LIBDB_CONFIG"))
end

function LoadoutReminder.INIT:ADDON_LOADED(addon_name)
	if addon_name ~= LoadoutReminderAddonName then
		return
	end
	LoadoutReminder.TALENTS:InitTalentManagement()
	-- init as soon as player specialization is available -- polling
	LoadoutReminder.INIT:Init()
end
