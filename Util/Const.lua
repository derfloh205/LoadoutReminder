---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

---@class LoadoutReminder.CONST
LoadoutReminder.CONST = {}

LoadoutReminder.CONST.INIT_POLL_INTERVAL = 0.5

LoadoutReminder.CONST.GENERAL_SELECTION_RGBA = { 1, 1, 1, 0.5 }
LoadoutReminder.CONST.GENERAL_HOVER_RGBA = { 1, 1, 1, 0.2 }
LoadoutReminder.CONST.SET_SELECTION_RGBA = { 0, 1, 0, 0.5 }
LoadoutReminder.CONST.SET_HOVER_RGBA = { 0, 1, 0, 0.2 }

LoadoutReminder.CONST.FRAMES = {
    REMINDER_FRAME = "TALENT_REMINDER_FRAME",
    NEWS = "NEWS",
    POPUP = "POPUP",
    OPTIONS = "OPTIONS",
}

LoadoutReminder.CONST.STARTER_BUILD = "Starter Build"
LoadoutReminder.CONST.LABEL_NO_SET = '-'
LoadoutReminder.CONST.NO_SET_NAME = '<No Set>'

---@type GGUI.BackdropOptions
LoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS = {
    backdropInfo = {
        bgFile = "Interface\\CharacterFrame\\UI-Party-Background",
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
        edgeSize = 16,
        insets = { left = 8, right = 6, top = 8, bottom = 8 },
    }
}
---@type GGUI.BackdropOptions
LoadoutReminder.CONST.OPTIONS_TAB_CONTENT_BACKDROP = {
    backdropInfo = {
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    }
}
---@enum LoadoutReminder.Raidboss
LoadoutReminder.CONST.BOSS_IDS = {
    DEFAULT = {
        DEFAULT = "DEFAULT",
    },
    AMIRDRASSIL = {
        DEFAULT = "DEFAULT",
        GNARLROOT = 'GNARLROOT',
        IGIRA = 'IGIRA',
        VOLCOROSS = 'VOLCOROSS',
        COUNCIL_OF_DREAMS = "COUNCIL_OF_DREAMS",
        LARODAR = "LARODAR",
        NYMUE = "NYMUE",
        SMOLDERON = "SMOLDERON",
        TINDRAL_SAGESWIFT = "TINDRAL_SAGESWIFT",
        FYRAKK = "FYRAKK",
    },
    ABERRUS = {
        DEFAULT = "DEFAULT",
        KAZZARA = 'KAZZARA',
        AMALGAMATION_CHAMBER = 'AMALGAMATION_CHAMBER',
        FORGOTTEN_EXPERIMENTS = 'FORGOTTEN_EXPERIMENTS',
        ASSAULT = 'ASSAULT',
        RASHOK = 'RASHOK',
        ZSKARN = 'ZSKARN',
        MAGMORAX = 'MAGMORAX',
        ECHO = 'ECHO',
        SARKARETH = 'SARKARETH',
    },
    VAULT_OF_THE_INCARNATES = {
        DEFAULT = "DEFAULT",
        ERANOG = "ERANOG",
        TERROS = "TERROS",
        PRIMAL_COUNCIL = "PRIMAL_COUNCIL",
        SENNARTH = "SENNARTH",
        DATHEA = "DATHEA",
        KUROG = "KUROG",
        DIURNA = "DIURNA",
        RASZAGETH = "RASZAGETH",
    },
}

---@type table<LoadoutReminder.Raids, table<LoadoutReminder.Raidboss, string>>
LoadoutReminder.CONST.BOSS_NAMES = {
    DEFAULT = {
        DEFAULT = "Any Boss",
    },
    AMIRDRASSIL = {
        DEFAULT = "Any Boss",
        GNARLROOT = 'Gnarlroot',
        IGIRA = 'Igira',
        VOLCOROSS = 'Volcoross',
        COUNCIL_OF_DREAMS = "Council of Dreams",
        LARODAR = "Larodar",
        NYMUE = "Nymue",
        SMOLDERON = "Smolderon",
        TINDRAL_SAGESWIFT = "Tindral Sageswift",
        FYRAKK = "Fyrakk",
    },
    ABERRUS = {
        DEFAULT = "Any Boss",
        KAZZARA = 'Kazzara',
        AMALGAMATION_CHAMBER = 'Chamber',
        FORGOTTEN_EXPERIMENTS = 'Experiments',
        ASSAULT = 'Assault',
        RASHOK = 'Rashok',
        ZSKARN = 'Zskarn',
        MAGMORAX = 'Magmorax',
        ECHO = 'Echo of Neltharion',
        SARKARETH = 'Sarkareth',
    },
    VAULT_OF_THE_INCARNATES = {
        DEFAULT = "Any Boss",
        ERANOG = "Eranog",
        TERROS = "Terros",
        PRIMAL_COUNCIL = "Primal Council",
        SENNARTH = "Sennarth",
        DATHEA = "Dathea",
        KUROG = "Kurog",
        DIURNA = "Diurna",
        RASZAGETH = "Raszageth",
    },
}

---@enum LoadoutReminder.Difficulty
LoadoutReminder.CONST.DIFFICULTY = {
    DEFAULT = "DEFAULT",
    LFR = "LFR",
    NORMAL = "NORMAL",
    HEROIC = "HEROIC",
    MYTHIC = "MYTHIC",
    TIMEWALKING = "TIMEWALKING",
}

LoadoutReminder.CONST.DIFFICULTY_DISPLAY_NAMES = {
    DEFAULT = "Any Difficulty",
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
---@type LoadoutReminder.Difficulty | string[]
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

---@class LoadoutReminder.RaidBossData
---@field boss string
---@field raid LoadoutReminder.Raids

---@type table<number, LoadoutReminder.RaidBossData>
LoadoutReminder.CONST.BOSS_ID_MAP = {
    [9999] = {
        boss = "DEFAULT",
        raid = "DEFAULT",
    },
    -- Amirdrassil (Dragonflight)
    [209333] = {
        boss = "GNARLROOT",
        raid = "AMIRDRASSIL",
    },
    [200926] = {
        boss = "IGIRA",
        raid = "AMIRDRASSIL",
    },
    [208478] = {
        boss = "VOLCOROSS",
        raid = "AMIRDRASSIL",
    },
    -- Council of Dreams: Urctos, Aerwynn, Pip
    [208363] = {
        boss = "COUNCIL_OF_DREAMS",
        raid = "AMIRDRASSIL",
    },
    [208365] = {
        boss = "COUNCIL_OF_DREAMS",
        raid = "AMIRDRASSIL",
    },
    [208367] = {
        boss = "COUNCIL_OF_DREAMS",
        raid = "AMIRDRASSIL",
    },
    [208445] = {
        boss = "LARODAR",
        raid = "AMIRDRASSIL",
    },
    [206172] = {
        boss = "NYMUE",
        raid = "AMIRDRASSIL",
    },
    [200927] = {
        boss = "SMOLDERON",
        raid = "AMIRDRASSIL",
    },
    [209090] = {
        boss = "TINDRAL_SAGESWIFT",
        raid = "AMIRDRASSIL",
    },
    [204931] = {
        boss = "FYRAKK",
        raid = "AMIRDRASSIL",
    },

    -- Aberrus (Dragonflight)
    -- Kazzara
    [201261] = {
        boss = "KAZZARA",
        raid = "AMIRDRASSIL",
    },
    -- Amalgamation Chamber
    [201774] = {
        boss = "AMALGAMATION_CHAMBER",
        raid = "AMIRDRASSIL",
    },
    [201773] = {
        boss = "AMALGAMATION_CHAMBER",
        raid = "AMIRDRASSIL",
    },
    [201934] = {
        boss = "AMALGAMATION_CHAMBER",
        raid = "AMIRDRASSIL",
    },
    -- Forgotten Experiments
    [200912] = {
        boss = "FORGOTTEN_EXPERIMENTS",
        raid = "AMIRDRASSIL",
    },
    [200913] = {
        boss = "FORGOTTEN_EXPERIMENTS",
        raid = "AMIRDRASSIL",
    },
    [200918] = {
        boss = "FORGOTTEN_EXPERIMENTS",
        raid = "AMIRDRASSIL",
    },
    -- Assault
    [199659] = {
        boss = "ASSAULT",
        raid = "AMIRDRASSIL",
    },
    [202791] = {
        boss = "ASSAULT",
        raid = "AMIRDRASSIL",
    },
    [205921] = {
        boss = "ASSAULT",
        raid = "AMIRDRASSIL",
    },
    [205617] = {
        boss = "ASSAULT",
        raid = "AMIRDRASSIL",
    },
    [200840] = {
        boss = "ASSAULT",
        raid = "AMIRDRASSIL",
    },
    [199703] = {
        boss = "ASSAULT",
        raid = "AMIRDRASSIL",
    },
    [200836] = {
        boss = "ASSAULT",
        raid = "AMIRDRASSIL",
    },
    [201320] = {
        boss = "RASHOK",
        raid = "AMIRDRASSIL",
    },
    [202637] = {
        boss = "ZSKARN",
        raid = "AMIRDRASSIL",
    },
    [201579] = {
        boss = "MAGMORAX",
        raid = "AMIRDRASSIL",
    },
    -- Echo of Neltharion
    [201668] = {
        boss = "ECHO",
        raid = "AMIRDRASSIL",
    },
    [203812] = {
        boss = "ECHO",
        raid = "AMIRDRASSIL",
    },
    [202814] = {
        boss = "ECHO",
        raid = "AMIRDRASSIL",
    },
    [201754] = {
        boss = "SARKARETH",
        raid = "AMIRDRASSIL",
    },

    -- Vault of the Incarnates (Dragonflight)
    [184972] = {
        boss = "ERANOG",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    [193459] = { -- DEBUG: Kadghar
        boss = "ERANOG",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    [190496] = {
        boss = "TERROS",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    -- Primal Council: Kadros Icewrath
    [187771] = {
        boss = "PRIMAL_COUNCIL",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    -- Primal Council: Dathea Stormlash
    [187768] = {
        boss = "PRIMAL_COUNCIL",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    -- Primal Council: Embar Firepath
    [187767] = {
        boss = "PRIMAL_COUNCIL",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    -- Primal Council: Opalfang
    [187772] = {
        boss = "PRIMAL_COUNCIL",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    [187967] = {
        boss = "SENNARTH",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    [189813] = {
        boss = "DATHEA",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    [181378] = {
        boss = "KUROG",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    [190245] = {
        boss = "DIURNA",
        raid = "VAULT_OF_THE_INCARNATES",
    },
    [189492] = {
        boss = "RASZAGETH",
        raid = "VAULT_OF_THE_INCARNATES",
    },
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

---@enum LoadoutReminder.ReminderTypes
LoadoutReminder.CONST.REMINDER_TYPES = {
    EQUIP = 'EQUIP',
    TALENTS = 'TALENTS',
    ADDONS = 'ADDONS',
    SPEC = 'SPEC',
}

LoadoutReminder.CONST.REMINDER_TYPES_DISPLAY_NAMES = {
    EQUIP = 'Equip Sets',
    TALENTS = 'Talent Sets',
    ADDONS = 'Addon Sets',
    SPEC = 'Specializations',
}

---@enum LoadoutReminder.Raids
LoadoutReminder.CONST.RAIDS = {
    DEFAULT = "DEFAULT",
    AMIRDRASSIL = 'AMIRDRASSIL',
    ABERRUS = 'ABERRUS',
    VAULT_OF_THE_INCARNATES = "VAULT_OF_THE_INCARNATES",
}

LoadoutReminder.CONST.RAID_DISPLAY_NAMES = {
    DEFAULT = "Any Raid",
    AMIRDRASSIL = 'Amirdrassil',
    ABERRUS = 'Aberrus',
    VAULT_OF_THE_INCARNATES = "Vault of the Incarnates",
}

---@enum LoadoutReminder.GeneralReminderTypes
LoadoutReminder.CONST.GENERAL_REMINDER_TYPES = {
    INSTANCE_TYPES = "INSTANCE_TYPES",
    RAID_BOSSES = "RAID_BOSSES",
}

LoadoutReminder.CONST.GENERAL_REMINDER_TYPES_DISPLAY_NAMES = {
    INSTANCE_TYPES = "Instance Types",
    RAID_BOSSES = "Raids",
}

--- List: https://wowpedia.fandom.com/wiki/InstanceID
LoadoutReminder.CONST.INSTANCE_IDS = {
    [2569] = 'ABERRUS',
    [2549] = 'AMIRDRASSIL',
    [2522] = "VAULT_OF_THE_INCARNATES",
}

LoadoutReminder.CONST.TEXTURES = {
    PAUSE_BUTTON = "Interface\\Addons\\LoadoutReminder\\Media\\PauseIcon",
}

---@enum LoadoutReminder.Const.Options
LoadoutReminder.CONST.OPTIONS = {
    NEWS_CHECKSUM = "NEWS_CHECKSUM",
    GGUI_CONFIG = "GGUI_CONFIG",
    LIBDB_CONFIG = "LIBDB_CONFIG",
    PER_BOSS_LOADOUTS = "PER_BOSS_LOADOUTS"
}

---@type table<LoadoutReminder.Const.Options, any>
LoadoutReminder.CONST.OPTION_DEFAULTS = {
    NEWS_CHECKSUM = nil,
    GGUI_CONFIG = {},
    LIBDB_CONFIG = {},
    PER_BOSS_LOADOUTS = {},
}
