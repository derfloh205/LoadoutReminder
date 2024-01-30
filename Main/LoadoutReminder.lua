---@class LoadoutReminder
local LoadoutReminder = select(2, ...)
local LoadoutReminderAddonName = select(1, ...)

---@class LoadoutReminder.MAIN : Frame
LoadoutReminder.MAIN = CreateFrame("Frame")
LoadoutReminder.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.MAIN:RegisterEvent("ADDON_LOADED")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_TARGET_CHANGED")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_ENTERING_WORLD")
LoadoutReminder.MAIN:RegisterEvent("PLAYER_LEAVE_COMBAT")
LoadoutReminder.MAIN:RegisterEvent("TRAIT_CONFIG_LIST_UPDATED")
LoadoutReminder.MAIN:RegisterEvent("TRAIT_CONFIG_CREATED")
LoadoutReminder.MAIN:RegisterEvent("TRAIT_CONFIG_DELETED")
LoadoutReminder.MAIN:RegisterEvent("TRAIT_CONFIG_UPDATED")

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
	LoadoutReminder.NEWS:Init()
	LoadoutReminder.ADDONS:Init()
	LoadoutReminder.MAIN:InitializeSlashCommands()
	LoadoutReminder.OPTIONS:Init()
	LoadoutReminder.REMINDER_FRAME.FRAMES:Init()

	-- restore frame positions
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES,
		LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	reminderFrame:RestoreSavedConfig(UIParent)
	local newsFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.NEWS)
	newsFrame:RestoreSavedConfig(UIParent)

	-- everything initalized
	LoadoutReminder.MAIN.READY = true

	-- Make first check after everything is loaded
	LoadoutReminder.CHECK:CheckSituations()

	-- show news
	LoadoutReminder.NEWS:ShowNews()
end

function LoadoutReminder.MAIN:ADDON_LOADED(addon_name)
	if addon_name ~= LoadoutReminderAddonName then
		return
	end
	LoadoutReminder.TALENTS:InitTalentManagement()
	-- init as soon as player specialization is available -- polling
	LoadoutReminder.MAIN:Init()
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

		if command == "config" then
			InterfaceOptionsFrame_OpenToCategory(LoadoutReminder.OPTIONS.optionsPanel)
		end

		if command == "check" then
			LoadoutReminder.CHECK:CheckSituations()
		end

		if command == "news" then
			LoadoutReminder.NEWS:ShowNews(true)
		end

		if command == "" then
			print("LoadoutReminder Help")
			print("/lor or /loadoutreminder can be used for following commands")
			print("/lor -> show help text")
			print("/lor news -> show last update news")
			print("/lor config -> show options panel")
			print("/lor check -> if configured check current player situation")
		end
	end
end

-- EVENTS
function LoadoutReminder.MAIN:PLAYER_TARGET_CHANGED()
	LoadoutReminder.CHECK:CheckSituations()
end

function LoadoutReminder.MAIN:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
	-- only when entering/exiting an instance, not on login or reload (thats where ADDON_LOADED fires)
	if isInitialLogin or isReloadingUi then
		return
	end
	LoadoutReminder.CHECK:CheckSituations()
end

function LoadoutReminder.MAIN:PLAYER_LEAVE_COMBAT()
	LoadoutReminder.CHECK:CheckSituations()
end

function LoadoutReminder.MAIN:TRAIT_CONFIG_LIST_UPDATED()
	RunNextFrame(function()
		LoadoutReminder.CHECK:CheckSituations()
		LoadoutReminder.OPTIONS:ReloadDropdowns()
	end)
end

function LoadoutReminder.MAIN:TRAIT_CONFIG_CREATED()
	RunNextFrame(function()
		LoadoutReminder.CHECK:CheckSituations()
		LoadoutReminder.OPTIONS:ReloadDropdowns()
	end)
end

function LoadoutReminder.MAIN:TRAIT_CONFIG_DELETED()
	RunNextFrame(function()
		LoadoutReminder.CHECK:CheckSituations()
		LoadoutReminder.OPTIONS:ReloadDropdowns()
	end)
end

function LoadoutReminder.MAIN:TRAIT_CONFIG_UPDATED()
	RunNextFrame(function()
		LoadoutReminder.CHECK:CheckSituations()
		LoadoutReminder.OPTIONS:ReloadDropdowns()
	end)
end
