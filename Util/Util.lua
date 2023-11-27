_, LoadoutReminder = ...

LoadoutReminder.UTIL = {}

function LoadoutReminder.UTIL:GetCurrentInstanceType()
	local inInstance, instanceType = IsInInstance()
	if inInstance then
		if instanceType == 'party' then
			return LoadoutReminder.CONST.INSTANCE_TYPES.DUNGEON
		elseif instanceType == 'raid' then
			return LoadoutReminder.CONST.INSTANCE_TYPES.RAID
		elseif instanceType == 'pvp' then
			return LoadoutReminder.CONST.INSTANCE_TYPES.BATTLEGROUND
		elseif instanceType == 'arena' then
			return LoadoutReminder.CONST.INSTANCE_TYPES.ARENA
		end
	elseif not inInstance then
		return LoadoutReminder.CONST.INSTANCE_TYPES.OPENWORLD
	end
end

---@return string | nil, string | nil
function LoadoutReminder.UTIL:CheckCurrentSetAgainstInstanceSetList(currentSet, generalSets)
	local instanceType = LoadoutReminder.UTIL:GetCurrentInstanceType()

	local instanceSet = generalSets[instanceType]

	if instanceSet == currentSet or instanceSet == nil then
		-- same set or no set assigned to this instance type
		return
	end

	return currentSet, instanceSet
end

local tryCount = 4
function LoadoutReminder.UTIL:IsNecessaryInfoLoaded()
	local _, type = IsInInstance()
	local talentSetRecognizeable = LoadoutReminder.TALENTS:CurrentSetRecognizable()
	local equipSetsLoaded = LoadoutReminder.EQUIP:AreEquipSetsLoaded()
	-- print("load infos: ")
	-- print("instanceType: " .. tostring(type))
	-- print("talentSetRecognizeable: " .. tostring(talentSetRecognizeable))
	-- print("equipSetsLoaded: " .. tostring(equipSetsLoaded))
	-- only try X times then load everything anyway
	if tryCount > 0 then
		tryCount = tryCount - 1
	else
		return true
	end
	return GetSpecialization() ~= nil and type ~= nil and talentSetRecognizeable and equipSetsLoaded
end

function LoadoutReminder.UTIL:UpdateReminderFrame(visibility, activeRemindersCount)
	-- TODO: introduce option to hide in combat
	---@type GGUI.Frame | GGUI.Widget
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)

	if activeRemindersCount == 1 then
		reminderFrame:SetStatus('ONE')
	elseif activeRemindersCount == 2 then
		reminderFrame:SetStatus('TWO')
	elseif activeRemindersCount == 3 then
		reminderFrame:SetStatus('THREE')
	elseif activeRemindersCount == 4 then
		reminderFrame:SetStatus('FOUR')
	end

	reminderFrame:SetVisible(visibility)
end