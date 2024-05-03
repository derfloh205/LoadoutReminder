---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

local GUTIL = LoadoutReminder.GUTIL

---@class LoadoutReminder.SPEC : Frame
LoadoutReminder.SPEC = GUTIL:CreateRegistreeForEvents { "PLAYER_SPECIALIZATION_CHANGED" }

---@param instanceType LoadoutReminder.InstanceTypes
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.SPEC:CheckInstanceSpecSet(instanceType, difficulty, specID)
	local assignedSpecID = LoadoutReminder.DB.SPEC:GetInstanceSet(instanceType, difficulty)

	print("checking spec for difficulty: " .. difficulty)

	-- print("currentSpecID: " .. tostring(specID))
	-- print("assignedSpecID: " .. tostring(assignedSpecID))
	-- print("instanceType: " .. tostring(instanceType))
	-- print("difficulty: " .. tostring(difficulty))

	if specID and assignedSpecID then
		local macroText = LoadoutReminder.SPEC:GetMacroTextBySet(assignedSpecID)
		local buttonText = 'Switch Spec to: '
		local currentSpecName = select(2, GetSpecializationInfoByID(specID))
		local assignedSpecName = select(2, GetSpecializationInfoByID(assignedSpecID))

		return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, 'Detected Situation: ', macroText,
			buttonText, "Spec", currentSpecName, assignedSpecName)
	end
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param difficulty LoadoutReminder.Difficulty
---@param specID SpecID
---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.SPEC:CheckBossSpecSet(raid, boss, difficulty, specID)
	local bossSetSpecID = LoadoutReminder.DB.SPEC:GetRaidBossSet(raid, boss, difficulty)

	print("checking spec boss set: " .. raid .. "-" .. boss .. "-" .. difficulty)

	if bossSetSpecID == nil then
		return nil
	end

	local macroText = LoadoutReminder.SPEC:GetMacroTextBySet(bossSetSpecID)
	local specName = select(2, GetSpecializationInfoByID(specID))
	local bossSetName = bossSetSpecID and select(2, GetSpecializationInfoByID(bossSetSpecID)) or ""
	return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, 'Detected Boss: ', macroText,
		'Switch Spec to: ', 'Spec', specName, bossSetName)
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
	LoadoutReminder.OPTIONS.FRAMES:UpdateSetListDisplay()
	LoadoutReminder.CHECK:CheckSituations()
end
