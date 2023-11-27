_, LoadoutReminder = ...

LoadoutReminder.SPEC = CreateFrame("Frame")
LoadoutReminder.SPEC:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
LoadoutReminder.SPEC:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")



---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.SPEC:CheckInstanceSpecSet()
    if LoadoutReminder.SPEC:HasRaidSpecPerBoss() then
		return
	end

	local INSTANCE_SETS = LoadoutReminderDB.SPEC.GENERAL
	local CURRENT_SET = LoadoutReminder.SPEC:GetCurrentSet()

	local currentSet, assignedSet = LoadoutReminder.UTIL:CheckCurrentSetAgainstInstanceSetList(CURRENT_SET, INSTANCE_SETS)

	if currentSet and assignedSet then
		local macroText = LoadoutReminder.SPEC:GetMacroTextBySet(assignedSet)
		local buttonText = 'Switch Spec to: '
		return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, 'Detected Situation: ', macroText, buttonText, "Spec", currentSet, assignedSet)
	end
end

---@return LoadoutReminder.ReminderInfo | nil
function LoadoutReminder.SPEC:CheckBossSpecSet(boss)
	local bossSet = LoadoutReminderDB.SPEC.BOSS[boss]

	if bossSet == nil then
		return nil
	end

	local currentSet = LoadoutReminder.SPEC:GetCurrentSet()
	local macroText = LoadoutReminder.SPEC:GetMacroTextBySet(bossSet)
	return LoadoutReminder.ReminderInfo(LoadoutReminder.CONST.REMINDER_TYPES.SPEC, 'Detected Boss: ', macroText, 'Switch Spec to: ', 'Spec', currentSet, bossSet)
end

function LoadoutReminder.SPEC:GetCurrentSet()
    local specID = GetSpecialization()
    return select(2, GetSpecializationInfo(specID))
end

function LoadoutReminder.SPEC:GetSpecSets()
    local specNames = {}

    for specIndex = 1, GetNumSpecializations() do
        local _, specName = GetSpecializationInfo(specIndex)
        table.insert(specNames, specName)
    end

    return specNames
end

function LoadoutReminder.SPEC:HasRaidSpecPerBoss()
    local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	local raid = LoadoutReminder.CONST.INSTANCE_IDS[instanceID]

	if not raid then
		return false
	end

	return LoadoutReminderOptions.SPEC.RAIDS_PER_BOSS[raid]
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
    LoadoutReminder.MAIN:CheckSituations()
end