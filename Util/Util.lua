_, LoadoutReminder = ...

LoadoutReminder.UTIL = {}

---@return string | nil, string | nil
function LoadoutReminder.UTIL:CheckCurrentSetAgainstGeneralSetList(CURRENT_SET, GENERAL_SETS)
    print("check sets")
    local inInstance, instanceType = IsInInstance()

    local DUNGEON_SET = GENERAL_SETS["DUNGEON"]
	local RAID_SET = GENERAL_SETS["RAID"]
	local BG_SET = GENERAL_SETS["BG"]
	local ARENA_SET = GENERAL_SETS["ARENA"]
	local OPENWORLD_SET = GENERAL_SETS["OPENWORLD"]

	-- check if player went into a dungeon
	if inInstance and instanceType == 'party' then
		if instanceType == 'party' then
			if DUNGEON_SET == CURRENT_SET or DUNGEON_SET == nil then
				--LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(DUNGEON_SET)
				return
			end
			return CURRENT_SET, DUNGEON_SET
		elseif instanceType == 'raid' then
			if RAID_SET == CURRENT_SET or RAID_SET == nil then
				--LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(RAID_SET)
				return
			end
			return CURRENT_SET, RAID_SET
		elseif instanceType == 'pvp' then
			if BG_SET == CURRENT_SET or BG_SET == nil then
				--LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(BG_SET)
				return
			end
			return CURRENT_SET, BG_SET
		elseif instanceType == 'arena' then
			if ARENA_SET == CURRENT_SET or ARENA_SET == nil then
				--LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(ARENA_SET)
				return
			end
			return CURRENT_SET, ARENA_SET
		end
	elseif not inInstance then
        print("not in instance")
		if OPENWORLD_SET == CURRENT_SET or OPENWORLD_SET == nil then
            print("same set or open world set nil")
			--LoadoutReminder.MAIN:PrintAlreadyLoadedMessage(OPENWORLD_SET)
			return
		end
        print("return open world set: " .. tostring(OPENWORLD_SET))
		return CURRENT_SET, OPENWORLD_SET
	end
end