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
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[instanceType] = LoadoutReminderDBV3.GENERAL[instanceType] or {}
	LoadoutReminderDBV3.GENERAL[instanceType].TALENTS = LoadoutReminderDBV3.GENERAL[instanceType].TALENTS or {}
	LoadoutReminderDBV3.GENERAL[instanceType].TALENTS[specID] = setID
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil the current instanceType will be taken
function LoadoutReminder.DB.TALENTS:GetInstanceSet(instanceType)
    instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	local specID = GetSpecialization()
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[instanceType] = LoadoutReminderDBV3.GENERAL[instanceType] or {}
	LoadoutReminderDBV3.GENERAL[instanceType].TALENTS = LoadoutReminderDBV3.GENERAL[instanceType].TALENTS or {}
	return LoadoutReminderDBV3.GENERAL[instanceType].TALENTS[specID]
end

---@param raid LoadoutReminder.Raids
---@param boss string
function LoadoutReminder.DB.TALENTS:GetRaidSet(raid, boss)
    local specID = GetSpecialization()
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[raid] = LoadoutReminderDBV3.RAIDS[raid] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss] = LoadoutReminderDBV3.RAIDS[raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss].TALENTS = LoadoutReminderDBV3.RAIDS[raid][boss].TALENTS or {}
	return LoadoutReminderDBV3.RAIDS[raid][boss].TALENTS[specID]
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param setID number | string
function LoadoutReminder.DB.TALENTS:SaveRaidSet(raid, boss, setID)
    local specID = GetSpecialization()
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[raid] = LoadoutReminderDBV3.RAIDS[raid] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss] = LoadoutReminderDBV3.RAIDS[raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss].TALENTS = LoadoutReminderDBV3.RAIDS[raid][boss].TALENTS or {}
	LoadoutReminderDBV3.RAIDS[raid][boss].TALENTS[specID] = setID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param setID number
function LoadoutReminder.DB.EQUIP:SaveInstanceSet(instanceType, setID)
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[instanceType] = LoadoutReminderDBV3.GENERAL[instanceType] or {}
	LoadoutReminderDBV3.GENERAL[instanceType].EQUIP = setID
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil the current type will be taken
function LoadoutReminder.DB.EQUIP:GetInstanceSet(instanceType)
    instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[instanceType] = LoadoutReminderDBV3.GENERAL[instanceType] or {}
	return LoadoutReminderDBV3.GENERAL[instanceType].EQUIP
end

---@param raid LoadoutReminder.Raids
---@param boss string
function LoadoutReminder.DB.EQUIP:GetRaidSet(raid, boss)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[raid] = LoadoutReminderDBV3.RAIDS[raid] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss] = LoadoutReminderDBV3.RAIDS[raid][boss] or {}
	return LoadoutReminderDBV3.RAIDS[raid][boss].EQUIP
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param setID number
function LoadoutReminder.DB.EQUIP:SaveRaidSet(raid, boss, setID)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[raid] = LoadoutReminderDBV3.RAIDS[raid] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss] = LoadoutReminderDBV3.RAIDS[raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss].EQUIP = setID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param setName string
function LoadoutReminder.DB.SPEC:SaveInstanceSet(instanceType, setName)
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[instanceType] = LoadoutReminderDBV3.GENERAL[instanceType] or {}
	LoadoutReminderDBV3.GENERAL[instanceType].SPEC = setName
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil -> current
function LoadoutReminder.DB.SPEC:GetInstanceSet(instanceType)
    instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[instanceType] = LoadoutReminderDBV3.GENERAL[instanceType] or {}
	return LoadoutReminderDBV3.GENERAL[instanceType].SPEC
end

---@param raid LoadoutReminder.Raids
---@param boss string
function LoadoutReminder.DB.SPEC:GetRaidSet(raid, boss)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[raid] = LoadoutReminderDBV3.RAIDS[raid] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss] = LoadoutReminderDBV3.RAIDS[raid][boss] or {}
	return LoadoutReminderDBV3.RAIDS[raid][boss].SPEC
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param setID number
function LoadoutReminder.DB.SPEC:SaveRaidSet(raid, boss, setID)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[raid] = LoadoutReminderDBV3.RAIDS[raid] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss] = LoadoutReminderDBV3.RAIDS[raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss].SPEC = setID
end

---@param instanceType LoadoutReminder.InstanceTypes
---@param setName string
function LoadoutReminder.DB.ADDONS:SaveInstanceSet(instanceType, setName)
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[instanceType] = LoadoutReminderDBV3.GENERAL[instanceType] or {}
	LoadoutReminderDBV3.GENERAL[instanceType].ADDONS = setName
end

---@param instanceType LoadoutReminder.InstanceTypes? if nil the current will be taken
function LoadoutReminder.DB.ADDONS:GetInstanceSet(instanceType)
    instanceType = instanceType or LoadoutReminder.UTIL:GetCurrentInstanceType()
	-- nil save
	LoadoutReminderDBV3.GENERAL = LoadoutReminderDBV3.GENERAL or {}
	LoadoutReminderDBV3.GENERAL[instanceType] = LoadoutReminderDBV3.GENERAL[instanceType] or {}
	return LoadoutReminderDBV3.GENERAL[instanceType].ADDONS
end

---@param raid LoadoutReminder.Raids
---@param boss string
function LoadoutReminder.DB.ADDONS:GetRaidSet(raid, boss)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[raid] = LoadoutReminderDBV3.RAIDS[raid] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss] = LoadoutReminderDBV3.RAIDS[raid][boss] or {}
	return LoadoutReminderDBV3.RAIDS[raid][boss].ADDONS
end

---@param raid LoadoutReminder.Raids
---@param boss string
---@param setID number
function LoadoutReminder.DB.ADDONS:SaveRaidSet(raid, boss, setID)
	-- nil save
	LoadoutReminderDBV3.RAIDS = LoadoutReminderDBV3.RAIDS or {}
	LoadoutReminderDBV3.RAIDS[raid] = LoadoutReminderDBV3.RAIDS[raid] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss] = LoadoutReminderDBV3.RAIDS[raid][boss] or {}
	LoadoutReminderDBV3.RAIDS[raid][boss].ADDONS = setID
end