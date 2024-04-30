---@class LoadoutReminder
local LoadoutReminder = select(2, ...)
local LoadoutReminderAddonName = select(1, ...)

local GUTIL = LoadoutReminder.GUTIL

---@class LoadoutReminder.MAIN : Frame
LoadoutReminder.MAIN = GUTIL:CreateRegistreeForEvents({ "ADDON_LOADED" })

LoadoutReminder.MAIN.FRAMES = {}
LoadoutReminder.MAIN.READY = false

LoadoutReminderGGUIConfig = LoadoutReminderGGUIConfig or {}

LoadoutReminderDBV3 = LoadoutReminderDBV3 or {}

LoadoutReminderOptionsV2 = LoadoutReminderOptionsV2 or {}

function LoadoutReminder.MAIN:Init()
	if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
		-- poll until info is available
		C_Timer.After(LoadoutReminder.CONST.INIT_POLL_INTERVAL, LoadoutReminder.MAIN.Init)
		return
	end
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
	LoadoutReminder.MAIN:InitializeSlashCommands()
	LoadoutReminder.OPTIONS:Init()
	LoadoutReminder.REMINDER_FRAME.FRAMES:Init()
	LoadoutReminder.MAIN:InitializeMinimapButton()

	-- restore frame positions
	local reminderFrame = LoadoutReminder.REMINDER_FRAME.frame
	reminderFrame:RestoreSavedConfig(UIParent)
	local newsFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.NEWS)
	if newsFrame then
		newsFrame:RestoreSavedConfig(UIParent)
	end

	-- everything initalized
	LoadoutReminder.MAIN.READY = true

	-- Make first check after everything is loaded
	LoadoutReminder.CHECK:CheckSituations()

	-- show news
	LoadoutReminder.NEWS:ShowNews()
end

function LoadoutReminder.MAIN:InitializeSlashCommands()
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
			InterfaceOptionsFrame_OpenToCategory(LoadoutReminder.OPTIONS.optionsPanel)
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

function LoadoutReminder.MAIN:InitializeMinimapButton()
	local LibIcon = LibStub("LibDBIcon-1.0")
	local libDB = LibStub("LibDataBroker-1.1")
	local ldb = libDB:NewDataObject("LoadoutReminder", {
		type = "data source",
		label = "LoadoutReminder",
		tocname = "LoadoutReminder",
		icon = "Interface\\Icons\\INV_Misc_Bell_01",
		OnClick = function()
			InterfaceOptionsFrame_OpenToCategory(LoadoutReminder.OPTIONS.optionsPanel)
		end,
	})

	function ldb.OnTooltipShow(tt)
		tt:AddLine("LoadoutReminder\n")
		tt:AddLine(GUTIL:ColorizeText("Click to Configure!", GUTIL.COLORS.WHITE))
	end

	LoadoutReminderLibIconDB = LoadoutReminderLibIconDB or {}

	LibIcon:Register("LoadoutReminder", ldb, LoadoutReminderLibIconDB)
end

function LoadoutReminder.MAIN:ADDON_LOADED(addon_name)
	if addon_name ~= LoadoutReminderAddonName then
		return
	end
	LoadoutReminder.TALENTS:InitTalentManagement()
	-- init as soon as player specialization is available -- polling
	LoadoutReminder.MAIN:Init()
end
