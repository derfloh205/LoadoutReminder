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

function LoadoutReminder.UTIL:IsNecessaryInfoLoaded()
	local _, type = IsInInstance()
	return GetSpecialization() ~= nil and type ~= nil
end

function LoadoutReminder.UTIL:ToggleFrame(visible)
	-- TODO: introduce option to hide in combat
	---@type GGUI.Frame | GGUI.Widget
	local reminderFrame = LoadoutReminder.GGUI:GetFrame(LoadoutReminder.MAIN.FRAMES, LoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	reminderFrame:SetVisible(visible)
end