LoadoutReminderAddonName, LoadoutReminder = ...

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
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	reminderFrame:RestoreSavedConfig(UIParent)
	local newsFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.NEWS)
	newsFrame:RestoreSavedConfig(UIParent)

	-- everything initalized
	LoadoutReminder.MAIN.READY = true

	-- Make first check after everything is loaded
	LoadoutReminder.MAIN.CheckSituations()

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

function LoadoutReminder.MAIN.CheckSituations()

	-- check only when player is not in combat and only if everything was initialized
	if not LoadoutReminder.MAIN.READY or UnitAffectingCombat('player') then
		return
	end

	local activeInstanceReminders = LoadoutReminder.MAIN:CheckInstanceTypes()
	local activeBossReminders = LoadoutReminder.MAIN:CheckBoss()

	local combinedActiveCount = LoadoutReminder.ActiveReminders:GetCombinedActiveRemindersCount({activeInstanceReminders, activeBossReminders})

	-- if any reminder is triggered: show frame, otherwise hide
	-- print('combinedActiveCount: ' .. tostring(combinedActiveCount))
	-- print('activeInstanceReminders: ' .. tostring(activeInstanceReminders:GetCount()))
	-- print('activeBossReminders: ' .. tostring(activeBossReminders:GetCount()))
	if combinedActiveCount > 0 then
		-- set status of frame depending on how many things are to be reminded of
		LoadoutReminder.UTIL:UpdateReminderFrame(true, LoadoutReminder.ActiveReminders:GetCombinedActiveRemindersCount({activeInstanceReminders, activeBossReminders}))
	else
		LoadoutReminder.UTIL:UpdateReminderFrame(false)
	end
end

---@return LoadoutReminder.ActiveReminders | nil
function LoadoutReminder.MAIN:CheckInstanceTypes()
	local activeReminders = LoadoutReminder.ActiveReminders(false, false, false, false)

	if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
		return activeReminders
	end

	local instanceType = LoadoutReminder.UTIL:GetCurrentInstanceType()

	if LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss() then
		-- print("ic: has raid loadouts per boss")
		-- Hide ReminderFrames
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, nil, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])		
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, nil, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, nil, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, nil, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
		return activeReminders
	end
	-- print("Check Instance Reminders")
	local talentReminderInfo = LoadoutReminder.TALENTS:CheckInstanceTalentSet()
	local addonReminderInfo = (LoadoutReminder.ADDONS.AVAILABLE and LoadoutReminder.ADDONS:CheckInstanceAddonSet()) or nil
	local equipReminderInfo = LoadoutReminder.EQUIP:CheckInstanceEquipSet()
	local specReminderInfo = LoadoutReminder.SPEC:CheckInstanceSpecSet()

	--  print("talentReminderInfo: " .. tostring(talentReminderInfo))
	--  print("addonReminderInfo: " .. tostring(addonReminderInfo))
	--  print("equipReminderInfo: " .. tostring(equipReminderInfo))
	--  print("specReminderInfo: " .. tostring(specReminderInfo))


	-- Update Talent Reminder
	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, talentReminderInfo, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])		

	-- Update Addon Reminder
	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, addonReminderInfo, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
	
	-- Update Equip Reminder
	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, equipReminderInfo, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])
	
	-- Update Spec Reminder
	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, specReminderInfo, LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES[instanceType])

	return LoadoutReminder.ActiveReminders(
		talentReminderInfo and not talentReminderInfo:IsAssignedSet(), 
		addonReminderInfo and not addonReminderInfo:IsAssignedSet(),
		equipReminderInfo and not equipReminderInfo:IsAssignedSet(),
		specReminderInfo and not specReminderInfo:IsAssignedSet()
	)
end

---@return LoadoutReminder.ActiveReminders | nil
function LoadoutReminder.MAIN:CheckBoss()
	local activeReminders = LoadoutReminder.ActiveReminders(false, false, false, false)
	if not LoadoutReminder.UTIL:IsNecessaryInfoLoaded() then
		return activeReminders
	end

	-- no raid loadouts per boss -> do not remind
	if not LoadoutReminder.OPTIONS:HasRaidLoadoutsPerBoss() then
		-- Hide ReminderFrames
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, nil, "", true)		
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, nil, "", true)
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, nil, "", true)
		LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, nil, "", true)
		return activeReminders
	end

	-- get name of player's target
	local npcID = LoadoutReminder.UTIL:GetTargetNPCID()
	if not npcID then
		return activeReminders -- no target
	end
	-- check npcID for boss
	local boss = LoadoutReminder.CONST.BOSS_ID_MAP[npcID]

	if boss == nil then
		return activeReminders -- npc is no boss
	end

	local raid = LoadoutReminder.UTIL:GetCurrentRaid()-- or LoadoutReminder.CONST.RAIDS.AMIRDRASSIL -- DEBUG

	if not raid then
		return
	end
	-- print("check boss reminders..")
	local talentReminderInfo = LoadoutReminder.TALENTS:CheckBossTalentSet(raid, boss)
	local addonReminderInfo = (LoadoutReminder.ADDONS.AVAILABLE and LoadoutReminder.ADDONS:CheckBossAddonSet(raid, boss)) or nil
	local equipReminderInfo = LoadoutReminder.EQUIP:CheckBossEquipSet(raid, boss)
	local specReminderInfo = LoadoutReminder.SPEC:CheckBossSpecSet(raid, boss)

	-- print("talentReminderInfo: " .. tostring(talentReminderInfo))
	-- print("addonReminderInfo: " .. tostring(addonReminderInfo))
	-- print("equipReminderInfo: " .. tostring(equipReminderInfo))
	-- print("specReminderInfo: " .. tostring(specReminderInfo))

	-- Update Talent Reminder
	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.TALENTS, talentReminderInfo, LoadoutReminder.CONST.BOSS_NAMES[boss], true)		

	-- Update Addon Reminder
	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.ADDONS, addonReminderInfo, LoadoutReminder.CONST.BOSS_NAMES[boss], true)
	
	-- Update Equip Reminder
	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.EQUIP, equipReminderInfo, LoadoutReminder.CONST.BOSS_NAMES[boss], true)
	
	-- Update Spec Reminder
	LoadoutReminder.REMINDER_FRAME:UpdateDisplay(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, specReminderInfo, LoadoutReminder.CONST.BOSS_NAMES[boss], true)

	return LoadoutReminder.ActiveReminders(
		talentReminderInfo and not talentReminderInfo:IsAssignedSet(), 
		addonReminderInfo and not addonReminderInfo:IsAssignedSet(),
		equipReminderInfo and not equipReminderInfo:IsAssignedSet(),
		specReminderInfo and not specReminderInfo:IsAssignedSet()
	)
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
			LoadoutReminder.MAIN:CheckSituations()
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
	LoadoutReminder.MAIN.CheckSituations()
end
function LoadoutReminder.MAIN:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi) 
	-- only when entering/exiting an instance, not on login or reload (thats where ADDON_LOADED fires)
	if isInitialLogin or isReloadingUi then
		return
	end
	LoadoutReminder.MAIN.CheckSituations()
end
function LoadoutReminder.MAIN:PLAYER_LEAVE_COMBAT() 
	LoadoutReminder.MAIN.CheckSituations()
end
function LoadoutReminder.MAIN:TRAIT_CONFIG_LIST_UPDATED() 
	RunNextFrame(function ()
		LoadoutReminder.MAIN.CheckSituations()
		LoadoutReminder.OPTIONS:ReloadDropdowns()
	end)
end
function LoadoutReminder.MAIN:TRAIT_CONFIG_CREATED() 
	RunNextFrame(function ()
		LoadoutReminder.MAIN.CheckSituations()
		LoadoutReminder.OPTIONS:ReloadDropdowns()
	end)
end
function LoadoutReminder.MAIN:TRAIT_CONFIG_DELETED() 
	RunNextFrame(function ()
		LoadoutReminder.MAIN.CheckSituations()
		LoadoutReminder.OPTIONS:ReloadDropdowns()
	end)
end
function LoadoutReminder.MAIN:TRAIT_CONFIG_UPDATED() 
	RunNextFrame(function ()
		LoadoutReminder.MAIN.CheckSituations()
		LoadoutReminder.OPTIONS:ReloadDropdowns()
	end)
end
