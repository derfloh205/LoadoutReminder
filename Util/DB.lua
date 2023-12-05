_ , LoadoutReminder = ...

LoadoutReminder.DB = {
    TALENTS = {},
    EQUIP = {},
    ADDONS = {},
    SPEC = {},
}

---@param instanceType LoadoutReminder.InstanceTypes
---@param setID number | string
function LoadoutReminder.DB.TALENTS:SaveInstanceSet(instanceType, setID)
	local specID = GetSpecialization()
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType)
	-- no need to make an exception for the default raid boss set cause its saved as boss anyway and there is no raid option in general
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty] = LoadoutReminderDBV3.GENERAL[selectedDifficulty] or {}

	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] = LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType].TALENTS = LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType].TALENTS or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType].TALENTS[specID] = setID
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil the current instanceType will be taken
---@param difficulty LoadoutReminder.DIFFICULTY? if nil the current instance difficulty will be taken
function LoadoutReminder.DB.TALENTS:GetInstanceSet(instanceType, difficulty)
    instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	local specID = GetSpecialization()
	local checkSituation = difficulty == nil
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty()
	if instanceType == LoadoutReminder.CONST.INSTANCE_TYPES.RAID then
		local function check(difficulty)
		-- get instance set is for default raid set, which is saved in the default raid as the default "boss" of that difficulty
			LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT.TALENTS = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT.TALENTS or {}
			return LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT.TALENTS[specID]
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
			LoadoutReminderDBV3.GENERAL[difficulty][instanceType] = LoadoutReminderDBV3.GENERAL[difficulty][instanceType] or {}
			LoadoutReminderDBV3.GENERAL[difficulty][instanceType].TALENTS = LoadoutReminderDBV3.GENERAL[difficulty][instanceType].TALENTS or {}
			return LoadoutReminderDBV3.GENERAL[difficulty][instanceType].TALENTS[specID]
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
---@param difficulty? LoadoutReminder.DIFFICULTY? if omitted -> take from current instance
function LoadoutReminder.DB.TALENTS:GetRaidSet(raid, boss, difficulty)
    local specID = GetSpecialization()
	local checkSituation = difficulty == nil
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty()
	local function check(difficulty)
		-- nil save
		LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
		LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid] = LoadoutReminderDBV3.RAIDS[difficulty][raid] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[difficulty][raid][boss] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid][boss].TALENTS = LoadoutReminderDBV3.RAIDS[difficulty][raid][boss].TALENTS or {}
		return LoadoutReminderDBV3.RAIDS[difficulty][raid][boss].TALENTS[specID]
	end

	-- if we are checking the situation fall back to default difficulty if there is no set for the chosen difficulty
	if checkSituation then
		return check(difficulty) or check(LoadoutReminder.CONST.DIFFICULTY.DEFAULT)
	end

	return check(difficulty)
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param setID number | string
function LoadoutReminder.DB.TALENTS:SaveRaidSet(raid, boss, setID)
    local specID = GetSpecialization()
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty] = LoadoutReminderDBV3.RAIDS[selectedDifficulty] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss].TALENTS = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss].TALENTS or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss].TALENTS[specID] = setID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param setID number
function LoadoutReminder.DB.EQUIP:SaveInstanceSet(instanceType, setID)
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType)
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty] = LoadoutReminderDBV3.GENERAL[selectedDifficulty] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] = LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType].EQUIP = setID
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil the current type will be taken
---@param difficulty LoadoutReminder.DIFFICULTY? if nil the current instance difficulty will be taken
function LoadoutReminder.DB.EQUIP:GetInstanceSet(instanceType, difficulty)
	local checkSituation = difficulty == nil
    instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty()
	if instanceType == LoadoutReminder.CONST.INSTANCE_TYPES.RAID then
		local function check(difficulty)
			-- get instance set is for default raid set, which is saved in the default raid as the default "boss" of that difficulty
			LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT or {}
			return LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT.EQUIP
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
			LoadoutReminderDBV3.GENERAL[difficulty][instanceType] = LoadoutReminderDBV3.GENERAL[difficulty][instanceType] or {}
			return LoadoutReminderDBV3.GENERAL[difficulty][instanceType].EQUIP
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
---@param difficulty? LoadoutReminder.DIFFICULTY? if omitted -> take from current instance
function LoadoutReminder.DB.EQUIP:GetRaidSet(raid, boss, difficulty)
	local checkSituation = difficulty == nil
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty()
	local function check(difficulty)
		-- nil save
		LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
		LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid] = LoadoutReminderDBV3.RAIDS[difficulty][raid] or {}
		LoadoutReminderDBV3.RAIDS[difficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[difficulty][raid][boss] or {}
		return LoadoutReminderDBV3.RAIDS[difficulty][raid][boss].EQUIP
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
function LoadoutReminder.DB.EQUIP:SaveRaidSet(raid, boss, setID)
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty] = LoadoutReminderDBV3.RAIDS[selectedDifficulty] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss].EQUIP = setID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param setName string
function LoadoutReminder.DB.SPEC:SaveInstanceSet(instanceType, setName)
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType)
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty] = LoadoutReminderDBV3.GENERAL[selectedDifficulty] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] = LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType].SPEC = setName
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil -> current
---@param difficulty LoadoutReminder.DIFFICULTY? if nil the current instance difficulty will be taken
function LoadoutReminder.DB.SPEC:GetInstanceSet(instanceType, difficulty)
	local checkSituation = difficulty == nil
    instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty()
	if instanceType == LoadoutReminder.CONST.INSTANCE_TYPES.RAID then
		local function check(difficulty)
			-- get instance set is for default raid set, which is saved in the default raid as the default "boss" of that difficulty
			LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT or {}
			return LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT.SPEC
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
			LoadoutReminderDBV3.GENERAL[difficulty][instanceType] = LoadoutReminderDBV3.GENERAL[difficulty][instanceType] or {}
			return LoadoutReminderDBV3.GENERAL[difficulty][instanceType].SPEC
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
---@param difficulty? LoadoutReminder.DIFFICULTY? if omitted -> take from current instance
function LoadoutReminder.DB.SPEC:GetRaidSet(raid, boss, difficulty)
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

---@param raid LoadoutReminder.Raids
---@param boss string
---@param setID number
function LoadoutReminder.DB.SPEC:SaveRaidSet(raid, boss, setID)
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty] = LoadoutReminderDBV3.RAIDS[selectedDifficulty] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss].SPEC = setID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param setName string
function LoadoutReminder.DB.ADDONS:SaveInstanceSet(instanceType, setName)
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(instanceType)
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty] = LoadoutReminderDBV3.GENERAL[selectedDifficulty] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] = LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType] or {}
	LoadoutReminderDBV3.GENERAL[selectedDifficulty][instanceType].ADDONS = setName
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil the current will be taken
---@param difficulty LoadoutReminder.DIFFICULTY? if nil the current instance difficulty will be taken
function LoadoutReminder.DB.ADDONS:GetInstanceSet(instanceType, difficulty)
	local checkSituation = difficulty == nil
    instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	difficulty = difficulty or LoadoutReminder.UTIL:GetInstanceDifficulty()
	if instanceType == LoadoutReminder.CONST.INSTANCE_TYPES.RAID then
		local function check(difficulty)
			-- get instance set is for default raid set, which is saved in the default raid as the default "boss" of that difficulty
			LoadoutReminderDBV3.RAIDS[difficulty] = LoadoutReminderDBV3.RAIDS[difficulty] or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT or {}
			LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT = LoadoutReminderDBV3.RAIDS[difficulty].DEFAULT.DEFAULT or {}
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
			LoadoutReminderDBV3.GENERAL[difficulty][instanceType] = LoadoutReminderDBV3.GENERAL[difficulty][instanceType] or {}
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
---@param difficulty? LoadoutReminder.DIFFICULTY? if omitted -> take from current instance
function LoadoutReminder.DB.ADDONS:GetRaidSet(raid, boss, difficulty)
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
function LoadoutReminder.DB.ADDONS:SaveRaidSet(raid, boss, setID)
	local selectedDifficulty = LoadoutReminder.OPTIONS:GetSelectedDifficultyBySupportedInstanceTypes(LoadoutReminder.CONST.INSTANCE_TYPES.RAID)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty] = LoadoutReminderDBV3.RAIDS[selectedDifficulty] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] = LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[selectedDifficulty][raid][boss].ADDONS = setID
end