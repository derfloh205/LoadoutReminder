---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.SPEC : Frame
LoadoutReminder.SPEC = CreateFrame("Frame")
LoadoutReminder.SPEC:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.SPEC:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")



---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.SPEC:CheckInstanceSpecSet()
	local currentSpecID = LoadoutReminder.SPEC:GetCurrentSet()
	local instanceType = LoadoutReminder.UTIL:GetCurrentInstanceType()
	local difficulty = LoadoutReminder.UTIL:GetInstanceDifficulty() or LoadoutReminder.CONST.DIFFICULTY.DEFAULT
	local assignedSpecID = LoadoutReminder.DB.SPEC:GetInstanceSet(instanceType, difficulty)

	if currentSpecID and assignedSpecID then
		local macroText = LoadoutReminder.SPEC:GetMacroTextBySet(assignedSpecID)
		local buttonText = 'Switch Spec to: '
		local specInfoInstantCurrent = LoadoutReminder.UTIL:GetSpecInfoInstant(select(3, UnitClass("player")),
			currentSpecID)
		local specInfoInstantAssigned = LoadoutReminder.UTIL:GetSpecInfoInstant(select(3, UnitClass("player")),
			assignedSpecID)
		return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, 'Detected Situation: ', macroText,
			buttonText, "Spec", specInfoInstantCurrent.name, specInfoInstantAssigned.name)
	end
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.SPEC:CheckBossSpecSet(raid, boss)
	local difficulty = LoadoutReminder.UTIL:GetInstanceDifficulty() or LoadoutReminder.CONST.DIFFICULTY.DEFAULT
	local bossSet = LoadoutReminder.DB.SPEC:GetRaidBossSet(raid, boss, difficulty)

	if bossSet == nil then
		return nil
	end

	local specID = LoadoutReminder.SPEC:GetCurrentSet()
	local macroText = LoadoutReminder.SPEC:GetMacroTextBySet(bossSet)
	local specInfoInstant = LoadoutReminder.UTIL:GetSpecInfoInstant(select(3, UnitClass("player")), specID)
	return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, 'Detected Boss: ', macroText,
		'Switch Spec to: ', 'Spec', specInfoInstant.name, bossSet)
end

function LoadoutReminder.SPEC:GetCurrentSet()
	local specID = GetSpecializationInfoForClassID(select(3, UnitClass("player")), GetSpecialization())
	return specID
end

function LoadoutReminder.SPEC:GetSpecSets()
	local specIDs = {}

	for specIndex = 1, GetNumSpecializations() do
		local specID, _ = GetSpecializationInfo(specIndex)
		table.insert(specIDs, specID)
	end

	return specIDs
end

function LoadoutReminder.SPEC:GetMacroTextBySet(assignedSet)
	-- spec id by name
	local specs = LoadoutReminder.SPEC:GetSpecSets()
	for index, value in pairs(specs) do
		if value == assignedSet then
			return '/run SetSpecialization(' .. index .. ')'
		end
	end
end

function LoadoutReminder.SPEC:PLAYER_SPECIALIZATION_CHANGED()
	LoadoutReminder.OPTIONS:ReloadDropdowns()
	LoadoutReminder.CHECK:CheckSituations()
end
