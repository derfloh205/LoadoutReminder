---@class LoadoutReminder
local LoadoutReminder = select(2, ...)

LoadoutReminder.CONST = {}

LoadoutReminder.CONST.INIT_POLL_INTERVAL = 0.5

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
    DEFAULT = "DEFAULT",
    -- Amirdrassil
    AMIRDRASSIL_GNARLROOT = "AMIRDRASSIL_GNARLROOT",
    AMIRDRASSIL_IGIRA = "AMIRDRASSIL_IGIRA",
    AMIRDRASSIL_VOLCOROSS = "AMIRDRASSIL_VOLCOROSS",
    AMIRDRASSIL_COUNCIL_OF_DREAMS = "AMIRDRASSIL_COUNCIL_OF_DREAMS",
    AMIRDRASSIL_LARODAR = "AMIRDRASSIL_LARODAR",
    AMIRDRASSIL_NYMUE = "AMIRDRASSIL_NYMUE",
    AMIRDRASSIL_SMOLDERON = "AMIRDRASSIL_SMOLDERON",
    AMIRDRASSIL_TINDRAL_SAGESWIFT = "AMIRDRASSIL_TINDRAL_SAGESWIFT",
    AMIRDRASSIL_FYRAKK = "AMIRDRASSIL_FYRAKK",
    -- Aberrus
    ABERRUS_KAZZARA = "ABERRUS_KAZZARA",
    ABERRUS_AMALGAMATION_CHAMBER = "ABERRUS_AMALGAMATION_CHAMBER",
    ABERRUS_FORGOTTEN_EXPERIMENTS = "ABERRUS_FORGOTTEN_EXPERIMENTS",
    ABERRUS_ASSAULT = "ABERRUS_ASSAULT",
    ABERRUS_RASHOK = "ABERRUS_RASHOK",
    ABERRUS_ZSKARN = "ABERRUS_ZSKARN",
    ABERRUS_MAGMORAX = "ABERRUS_MAGMORAX",
    ABERRUS_ECHO = "ABERRUS_ECHO",
    ABERRUS_SARKARETH = "ABERRUS_SARKARETH",
    -- Vault of the Incarnates
    VAULT_OF_THE_INCARNATES_ERANOG = "VAULT_OF_THE_INCARNATES_ERANOG",
    VAULT_OF_THE_INCARNATES_TERROS = "VAULT_OF_THE_INCARNATES_TERROS",
    VAULT_OF_THE_INCARNATES_PRIMAL_COUNCIL = "VAULT_OF_THE_INCARNATES_PRIMAL_COUNCIL",
    VAULT_OF_THE_INCARNATES_SENNARTH = "VAULT_OF_THE_INCARNATES_SENNARTH",
    VAULT_OF_THE_INCARNATES_DATHEA = "VAULT_OF_THE_INCARNATES_DATHEA",
    VAULT_OF_THE_INCARNATES_KUROG = "VAULT_OF_THE_INCARNATES_KUROG",
    VAULT_OF_THE_INCARNATES_DIURNA = "VAULT_OF_THE_INCARNATES_DIURNA",
    VAULT_OF_THE_INCARNATES_RASZAGETH = "VAULT_OF_THE_INCARNATES_RASZAGETH",
}

---@type table<LoadoutReminder.Raidboss, string>
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
    ABERRUS_KAZZARA = 'Kazzara',
    ABERRUS_AMALGAMATION_CHAMBER = 'Chamber',
    ABERRUS_FORGOTTEN_EXPERIMENTS = 'Experiments',
    ABERRUS_ASSAULT = 'Assault',
    ABERRUS_RASHOK = 'Rashok',
    ABERRUS_ZSKARN = 'Zskarn',
    ABERRUS_MAGMORAX = 'Magmorax',
    ABERRUS_ECHO = 'Echo of Neltharion',
    ABERRUS_SARKARETH = 'Sarkareth',
    -- Vault of the Incarnates
    VAULT_OF_THE_INCARNATES_ERANOG = "Eranog",
    VAULT_OF_THE_INCARNATES_TERROS = "Terros",
    VAULT_OF_THE_INCARNATES_PRIMAL_COUNCIL = "Primal Council",
    VAULT_OF_THE_INCARNATES_SENNARTH = "Sennarth",
    VAULT_OF_THE_INCARNATES_DATHEA = "Dathea",
    VAULT_OF_THE_INCARNATES_KUROG = "Kurog",
    VAULT_OF_THE_INCARNATES_DIURNA = "Diurna",
    VAULT_OF_THE_INCARNATES_RASZAGETH = "Raszageth",
}

---@type table<LoadoutReminder.Raidboss, number>
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
    -- Vault of the Incarnates
    VAULT_OF_THE_INCARNATES_ERANOG = 1,
    VAULT_OF_THE_INCARNATES_TERROS = 2,
    VAULT_OF_THE_INCARNATES_PRIMAL_COUNCIL = 3,
    VAULT_OF_THE_INCARNATES_SENNARTH = 4,
    VAULT_OF_THE_INCARNATES_DATHEA = 5,
    VAULT_OF_THE_INCARNATES_KUROG = 6,
    VAULT_OF_THE_INCARNATES_DIURNA = 7,
    VAULT_OF_THE_INCARNATES_RASZAGETH = 8,
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

---@type table<number, LoadoutReminder.Raidboss>
LoadoutReminder.CONST.BOSS_ID_MAP = {
    [9999] = "DEFAULT",
    -- Amirdrassil (Dragonflight)
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

    -- Aberrus (Dragonflight)
    -- Kazzara
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

    -- Vault of the Incarnates (Dragonflight)
    [184972] = "VAULT_OF_THE_INCARNATES_ERANOG",
    [193459] = "VAULT_OF_THE_INCARNATES_ERANOG", -- debug: kadghar
    [190496] = "VAULT_OF_THE_INCARNATES_TERROS",
    -- Primal Council: Kadros Icewrath
    [187771] = "VAULT_OF_THE_INCARNATES_PRIMAL_COUNCIL",
    -- Primal Council: Dathea Stormlash
    [187768] = "VAULT_OF_THE_INCARNATES_PRIMAL_COUNCIL",
    -- Primal Council: Embar Firepath
    [187767] = "VAULT_OF_THE_INCARNATES_PRIMAL_COUNCIL",
    -- Primal Council: Opalfang
    [187772] = "VAULT_OF_THE_INCARNATES_PRIMAL_COUNCIL",
    [187967] = "VAULT_OF_THE_INCARNATES_SENNARTH",
    [189813] = "VAULT_OF_THE_INCARNATES_DATHEA",
    [181378] = "VAULT_OF_THE_INCARNATES_KUROG",
    [190245] = "VAULT_OF_THE_INCARNATES_DIURNA",
    [189492] = "VAULT_OF_THE_INCARNATES_RASZAGETH",
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
    VAULT_OF_THE_INCARNATES = "VAULT_OF_THE_INCARNATES",
}

LoadoutReminder.CONST.RAID_DISPLAY_NAMES = {
    DEFAULT = "All Raids",
    AMIRDRASSIL = 'Amirdrassil',
    ABERRUS = 'Aberrus',
    VAULT_OF_THE_INCARNATES = "Vault of the Incarnates",
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
