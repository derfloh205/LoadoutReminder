---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

LoadoutReminder.UTIL = {}
local debug = false

function LoadoutReminder.UTIL:GetCurrentInstanceType()
	-- -- DEBUG
	if debug then
		return LoadoutReminder.CONST.INSTANCE_TYPES.RAID
	end

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

function LoadoutReminder.UTIL:GetCurrentRaid()
	-- DEBUG
	if debug then
		return LoadoutReminder.CONST.INSTANCE_IDS[2522] -- GetInstanceInfo() -> 8
	end
	return LoadoutReminder.CONST.INSTANCE_IDS[select(8, GetInstanceInfo())]
end

---@return LoadoutReminder.Difficulty difficulty
function LoadoutReminder.UTIL:GetInstanceDifficulty()
	return LoadoutReminder.CONST.DIFFICULTY_ID_MAP[select(3, GetInstanceInfo())]
end

function LoadoutReminder.UTIL:InstanceTypeSupportsDifficulty(instanceType)
	if instanceType == LoadoutReminder.CONST.INSTANCE_TYPES.DUNGEON then
		return true
	end
	if instanceType == LoadoutReminder.CONST.INSTANCE_TYPES.RAID then
		return true
	end

	return false
end

local tryCount = 10
function LoadoutReminder.UTIL:IsNecessaryInfoLoaded()
	local _, type = IsInInstance()
	local talentSetRecognizeable = LoadoutReminder.TALENTS:CurrentSetRecognizable()
	local equipSetsLoaded = LoadoutReminder.EQUIP:AreEquipSetsLoaded()
	local numSpecsExists = GetNumSpecializations() and GetNumSpecializations() > 0
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
	return GetSpecialization() ~= nil and type ~= nil and talentSetRecognizeable and equipSetsLoaded and numSpecsExists
end

function LoadoutReminder.UTIL:UpdateReminderFrame(visibility, activeRemindersCount)
	-- TODO: introduce option to hide in combat
	---@type GGUI.Frame | GGUI.Widget
	local reminderFrame = LoadoutReminder.REMINDER_FRAME.frame

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

function LoadoutReminder.UTIL:FindAndReplaceSetInDB(oldSet, newSet, saveTable, perSpecID)
	-- update saved loadouts for GENERAL
	for specID, instanceTalents in pairs(saveTable.GENERAL) do
		for instanceType, assignedTalentSet in pairs(instanceTalents) do
			if assignedTalentSet == oldSet then
				if perSpecID then
					saveTable.GENERAL[specID][instanceType] = newSet
				else
					saveTable.GENERAL[instanceType] = newSet
				end
				return
			end
		end
	end
	-- update saved loadouts for BOSSES
	for specID, instanceTalents in pairs(saveTable.BOSS) do
		for instanceType, assignedTalentSet in pairs(instanceTalents) do
			if assignedTalentSet == oldSet then
				if perSpecID then
					saveTable.BOSS[specID][instanceType] = newSet
				else
					saveTable.BOSS[instanceType] = newSet
				end
				return
			end
		end
	end
end

function LoadoutReminder.UTIL:GetTargetNPCID()
	if UnitExists("target") then
		local targetGUID = UnitGUID("target")
		local _, _, _, _, _, npcID = strsplit("-", targetGUID)

		return tonumber(npcID)
	end

	return nil
end

---@class LoadoutReminder.SpecializationInfo
---@field id number
---@field name string
---@field description string
---@field icon integer
---@field role string
---@field recommended boolean
---@field allowedForBoost boolean
---@field masterySpell1 number?
---@field masterySpell2 number?

---@param classID number
---@param specID SpecID
---@return LoadoutReminder.SpecializationInfo specInfoInstant
function LoadoutReminder.UTIL:GetSpecInfoInstant(classID, specID)
	-- get spec name with forClassID api.. because somehow GetSpecializationInfo(specID) does not return anything on addon load?!
	if specID then
		for i = 1, 4 do
			local specData = { GetSpecializationInfoForClassID(classID, i) }
			if specData[1] == specID then
				return {
					id = specData[1],
					name = specData[2],
					description = specData[3],
					icon = specData[4],
					role = specData[5],
					recommended = specData[6],
					allowedForBoost = specData[7],
					masterySpell1 = specData[8],
					masterySpell2 = specData[9],
				}
			end
		end
	end

	return {}
end
