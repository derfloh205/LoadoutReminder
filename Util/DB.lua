---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.DB_old
LoadoutReminder.DB_old = {
	TALENTS = {},
	EQUIP = {},
	ADDONS = {},
	SPEC = {},
}

---@param raid LoadoutReminder.Raids
---@param boss string
---@param difficulty? LoadoutReminder.Difficulty? if omitted -> take from current instance
function LoadoutReminder.DB_old.SPEC:GetRaidSet(raid, boss, difficulty)
	local checkSituation = difficulty == nil
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty()
	local function check(difficulty)
		-- nil save
		LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
		LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid] = LoadoutReminderDBV3.RAIDS[difficulty][raid] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[difficulty][raid][boss] or {}
		return LoadoutReminderDBV3.RAIDS[difficulty][raid][boss].SPEC
	end
	-- if we are checking the situation fall back to default difficulty if there is no set for the chosen difficulty
	if checkSituation then
		return check(difficulty) or check(LoadoutReminder.CONST.DIFFICULTY.DEFAULT)
	end

	return check(difficulty)
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param setName string
function LoadoutReminder.DB_old.ADDONS:SaveInstanceSet(instanceType, setName)
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType)
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty] = LoadoutReminderDBV3.GENERAL[selectedDifficulty] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] = LoadoutReminderDBV3.GENERAL[selectedDifficulty]
		[instanceType] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType].ADDONS = setName
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil the current will be taken
---@param difficulty LoadoutReminder.Difficulty? if nil the current instance difficulty will be taken
function LoadoutReminder.DB_old.ADDONS:GetInstanceSet(instanceType, difficulty)
	local checkSituation = difficulty == nil
	instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty() or LoadoutReminder.CONST.DIFFICULTY.DEFAULT
	if instanceType == LoadoutReminder.CONST.INSTANCE_TYPES.RAID then
		local function check(difficulty)
			-- get instance set is for default raid set, which is saved in the default raid as the default "boss" of that difficulty
			LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT
				.DEFAULT or {}
			return LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT.ADDONS
		end
		-- if we are checking the situation fall back to default difficulty if there is no set for the chosen difficulty
		if checkSituation then
			return check(difficulty) or check(LoadoutReminder.CONST.DIFFICULTY.DEFAULT)
		end

		return check(difficulty)
	else
		local function check(difficulty)
			-- nil save
			LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
			LoadoutReminderDBV3.GENERAL[difficulty] = LoadoutReminderDBV3.GENERAL[difficulty] or {}
			LoadoutReminderDBV3.GENERAL[difficulty][instanceType] = LoadoutReminderDBV3.GENERAL[difficulty]
				[instanceType] or {}
			return LoadoutReminderDBV3.GENERAL[difficulty][instanceType].ADDONS
		end
		-- if we are checking the situation fall back to default difficulty if there is no set for the chosen difficulty
		if checkSituation then
			return check(difficulty) or check(LoadoutReminder.CONST.DIFFICULTY.DEFAULT)
		end

		return check(difficulty)
	end
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param difficulty? LoadoutReminder.Difficulty? if omitted -> take from current instance
function LoadoutReminder.DB_old.ADDONS:GetRaidSet(raid, boss, difficulty)
	local checkSituation = difficulty == nil
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty()
	local function check(difficulty)
		-- nil save
		LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
		LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid] = LoadoutReminderDBV3.RAIDS[difficulty][raid] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[difficulty][raid][boss] or {}
		return LoadoutReminderDBV3.RAIDS[difficulty][raid][boss].ADDONS
	end
	-- if we are checking the situation fall back to default difficulty if there is no set for the chosen difficulty
	if checkSituation then
		return check(difficulty) or check(LoadoutReminder.CONST.DIFFICULTY.DEFAULT)
	end

	return check(difficulty)
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param setID number
function LoadoutReminder.DB_old.ADDONS:SaveRaidSet(raid, boss, setID)
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder
		.CONST.INSTANCE_TYPES.RAID)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty] = LoadoutReminderDBV3.RAIDS[selectedDifficulty] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid]
		[boss] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss].ADDONS = setID
end
