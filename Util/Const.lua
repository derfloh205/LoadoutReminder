---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

LoadoutReminder.CONST = {}

LoadoutReminder.CONST.INIT_POLL_INTERVAL = 0.5

LoadoutReminder.CONST.FRAMES = {
    REMINDER_FRAME = "TALENT_REMINDER_FRAME",
    NEWS = "NEWS"
}

LoadoutReminder.CONST.STARTER_BUILD = "Starter Build"
LoadoutReminder.CONST.LABEL_NO_SET = '-'
LoadoutReminder.CONST.NO_SET_NAME = '<No Set>'

LoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS = {
    bgFile = "Interface\\CharacterFrame\\UI-Party-Background",
    borderOptions = {
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
        edgeSize = 16,
        insets = { left = 8, right = 6, top = 8, bottom = 8 },
    }
}

LoadoutReminder.CONST.BOSS_NAMES = {
    DEFAULT = "All Bosses",
    -- Amirdrassil
    AMIRDRASSIL_GNARLROOT = 'Gnarlroot',
    AMIRDRASSIL_IGIRA = 'Igira',
    AMIRDRASSIL_VOLCOROSS = 'Volcoross',
    AMIRDRASSIL_COUNCIL_OF_DREAMS = "Council of Dreams",
    AMIRDRASSIL_LARODAR = "Larodar",
    AMIRDRASSIL_NYMUE = "Nymue",
    AMIRDRASSIL_SMOLDERON = "Smolderon",
    AMIRDRASSIL_TINDRAL_SAGESWIFT = "Tindral Sageswift",
    AMIRDRASSIL_FYRAKK = "Fyrakk",
    -- Aberrus
    ABERRUS_KAZZARA = 'Kazzara, the Hellforged',
    ABERRUS_AMALGAMATION_CHAMBER = 'The Amalgamation Chamber',
    ABERRUS_FORGOTTEN_EXPERIMENTS = 'The Forgotten Experiments',
    ABERRUS_ASSAULT = 'Assault of the Zaqali',
    ABERRUS_RASHOK = 'Rashok, the Elder',
    ABERRUS_ZSKARN = 'The Vigilant Steward, Zskarn',
    ABERRUS_MAGMORAX = 'Magmorax',
    ABERRUS_ECHO = 'Echo of Neltharion',
    ABERRUS_SARKARETH = 'Scalecommander Sarkareth',
}

LoadoutReminder.CONST.BOSS_SORT_ORDER = {
    DEFAULT = 0,
    -- Amirdrassil
    AMIRDRASSIL_GNARLROOT = 1,
    AMIRDRASSIL_IGIRA = 2,
    AMIRDRASSIL_VOLCOROSS = 3,
    AMIRDRASSIL_COUNCIL_OF_DREAMS = 4,
    AMIRDRASSIL_LARODAR = 5,
    AMIRDRASSIL_NYMUE = 6,
    AMIRDRASSIL_SMOLDERON = 7,
    AMIRDRASSIL_TINDRAL_SAGESWIFT = 8,
    AMIRDRASSIL_FYRAKK = 9,
    -- Aberrus
    ABERRUS_KAZZARA = 1,
    ABERRUS_AMALGAMATION_CHAMBER = 2,
    ABERRUS_FORGOTTEN_EXPERIMENTS = 3,
    ABERRUS_ASSAULT = 4,
    ABERRUS_RASHOK = 5,
    ABERRUS_ZSKARN = 6,
    ABERRUS_MAGMORAX = 7,
    ABERRUS_ECHO = 8,
    ABERRUS_SARKARETH = 9,
}

---@enum LoadoutReminder.DIFFICULTY
LoadoutReminder.CONST.DIFFICULTY = {
    DEFAULT = "DEFAULT",
    LFR = "LFR",
    NORMAL = "NORMAL",
    HEROIC = "HEROIC",
    MYTHIC = "MYTHIC",
    TIMEWALKING = "TIMEWALKING",
}

LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES = {
    DEFAULT = "All Difficulties",
    LFR = "LFR",
    NORMAL = "Normal",
    HEROIC = "Heroic",
    MYTHIC = "Mythic",
    TIMEWALKING = "Timewalking",
}

LoadoutReminder.CONST.DIFFICULTY_SORT_ORDER = {
    DEFAULT = 0,
    LFR = 1,
    NORMAL = 2,
    HEROIC = 3,
    MYTHIC = 4,
    TIMEWALKING = 5,
}

--- https://warcraft.wiki.gg/wiki/DifficultyID
---@type LoadoutReminder.DIFFICULTY | string[]
LoadoutReminder.CONST.DIFFICULTY_ID_MAP = {
    [9999] = "DEFAULT",   -- wildcard
    [1] = "NORMAL",       -- party
    [2] = "HEROIC",       -- party
    [3] = "NORMAL",       -- raid 10
    [4] = "NORMAL",       -- raid 25
    [5] = "HEROIC",       -- raid 10
    [6] = "HEROIC",       -- raid 25
    [7] = "LFR",          -- legacy
    [8] = "MYTHIC",       -- party
    [9] = "NORMAL",       -- raid
    [14] = "NORMAL",      -- raid
    [15] = "HEROIC",      -- raid
    [16] = "MYTHIC",      -- raid
    [17] = "LFR",         -- raid
    [23] = "MYTHIC",      -- party
    [24] = "TIMEWALKING", -- party
    [33] = "TIMEWALKING", -- raid
    [39] = "HEROIC",      -- scenario
    [150] = "NORMAL",     -- party
    [151] = "LFR",        -- lfr timewalking
}

-- TODO: Gather data
LoadoutReminder.CONST.BOSS_ID_MAP = {
    [9999] = "DEFAULT",
    -- Amirdrassil
    [209333] = 'AMIRDRASSIL_GNARLROOT',
    --[205772] = 'AMIRDRASSIL_GNARLROOT', --debug Kalecgos
    --[213930] = 'AMIRDRASSIL_GNARLROOT', --debug Koszaru
    [200926] = 'AMIRDRASSIL_IGIRA',
    [208478] = 'AMIRDRASSIL_VOLCOROSS',
    -- Council of Dreams: Urctos, Aerwynn, Pip
    [208363] = 'AMIRDRASSIL_COUNCIL_OF_DREAMS',
    [208365] = 'AMIRDRASSIL_COUNCIL_OF_DREAMS',
    [208367] = 'AMIRDRASSIL_COUNCIL_OF_DREAMS',
    [208445] = 'AMIRDRASSIL_LARODAR',
    [206172] = 'AMIRDRASSIL_NYMUE',
    [200927] = 'AMIRDRASSIL_SMOLDERON',
    [209090] = 'AMIRDRASSIL_TINDRAL_SAGESWIFT',
    [204931] = 'AMIRDRASSIL_FYRAKK',
    [201261] = 'ABERRUS_KAZZARA',
    -- Amalgamation Chamber
    [201774] = 'ABERRUS_AMALGAMATION_CHAMBER',
    [201773] = 'ABERRUS_AMALGAMATION_CHAMBER',
    [201934] = 'ABERRUS_AMALGAMATION_CHAMBER',
    -- Forgotten Experiments
    [200912] = 'ABERRUS_FORGOTTEN_EXPERIMENTS',
    [200913] = 'ABERRUS_FORGOTTEN_EXPERIMENTS',
    [200918] = 'ABERRUS_FORGOTTEN_EXPERIMENTS',
    -- Assault
    [199659] = 'ABERRUS_ASSAULT',
    [202791] = 'ABERRUS_ASSAULT',
    [205921] = 'ABERRUS_ASSAULT',
    [205617] = 'ABERRUS_ASSAULT',
    [200840] = 'ABERRUS_ASSAULT',
    [199703] = 'ABERRUS_ASSAULT',
    [200836] = 'ABERRUS_ASSAULT',
    [201320] = 'ABERRUS_RASHOK',
    [202637] = 'ABERRUS_ZSKARN',
    [201579] = 'ABERRUS_MAGMORAX',
    -- Echo of Neltharion
    [201668] = 'ABERRUS_ECHO',
    [203812] = 'ABERRUS_ECHO',
    [202814] = 'ABERRUS_ECHO',
    [201754] = 'ABERRUS_SARKARETH',
}

LoadoutReminder.CONST.ADDON_LIST_ADDONS = {
    BETTER_ADDON_LIST = "BetterAddonList",
    ADDON_CONTROL_PANEL = "AddonControlPanel",
}

LoadoutReminder.CONST.TALENT_MANAGEMENT_ADDONS = {
    TALENTLOADOUTMANAGER = "TalentLoadoutManager",
}

---@enum LoadoutReminder.InstanceTypes
LoadoutReminder.CONST.INSTANCE_TYPES = {
    DUNGEON = 'DUNGEON',
    RAID = 'RAID',
    OPENWORLD = 'OPENWORLD',
    BG = 'BG',
    ARENA = 'ARENA',
}

-- Map<Enum, displayName>
LoadoutReminder.CONST.INSTANCE_TYPES_DISPLAY_NAMES = {
    DUNGEON = 'Dungeon',
    RAID = 'Raid',
    BG = 'Battleground',
    ARENA = 'Arena',
    OPENWORLD = 'Open World',
}

---@enum LoadoutReminder.REMINDER_TYPES
LoadoutReminder.CONST.REMINDER_TYPES = {
    EQUIP = 'EQUIP',
    TALENTS = 'TALENTS',
    ADDONS = 'ADDONS',
    SPEC = 'SPEC',
}

---@enum LoadoutReminder.Raids
LoadoutReminder.CONST.RAIDS = {
    DEFAULT = "DEFAULT",
    AMIRDRASSIL = 'AMIRDRASSIL',
    ABERRUS = 'ABERRUS',
}

LoadoutReminder.CONST.RAID_DISPLAY_NAMES = {
    DEFAULT = "All Raids",
    AMIRDRASSIL = 'Amirdrassil',
    ABERRUS = 'Aberrus',
}

--- List: https://wowpedia.fandom.com/wiki/InstanceID
LoadoutReminder.CONST.INSTANCE_IDS = {
    [2569] = 'ABERRUS',
    [2549] = 'AMIRDRASSIL'
}
