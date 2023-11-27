_, LoadoutReminder = ...

LoadoutReminder.CONST = {}

LoadoutReminder.CONST.INIT_POLL_INTERVAL = 0.5

LoadoutReminder.CONST.FRAMES = {
    REMINDER_FRAME = "TALENT_REMINDER_FRAME",
}

LoadoutReminder.CONST.STARTER_BUILD = "Starter Build"

LoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS = {
    bgFile = "Interface\\CharacterFrame\\UI-Party-Background",
    borderOptions = {
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
        edgeSize = 16,
        insets = { left = 8, right = 6, top = 8, bottom = 8 },
    }
}

LoadoutReminder.CONST.BOSS_NAMES = {
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

-- TODO: Gather data
LoadoutReminder.CONST.BOSS_ID_MAP = {
    -- Amirdrassil
    [209333] = 'AMIRDRASSIL_GNARLROOT',
    [201574] = 'AMIRDRASSIL_GNARLROOT', -- debug
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
    -- Aberrus TODO: get IDs
    [209333] = 'ABERRUS_KAZZARA',
    [201574] = 'ABERRUS_AMALGAMATION_CHAMBER', -- debug Wrathion
    [200926] = 'ABERRUS_FORGOTTEN_EXPERIMENTS',
    [208478] = 'ABERRUS_ASSAULT',
    [208363] = 'ABERRUS_RASHOK',
    [208365] = 'ABERRUS_ZSKARN',
    [208367] = 'ABERRUS_MAGMORAX',
    [208445] = 'ABERRUS_ECHO',
    [206172] = 'ABERRUS_SARKARETH',
}

LoadoutReminder.CONST.ADDON_LIST_ADDONS = {
    BETTER_ADDON_LIST = "BetterAddonList",
    ADDON_CONTROL_PANEL = "AddonControlPanel",
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
    OPENWORLD = 'Open World',
    BG = 'Battleground',
    ARENA = 'Arena',
}

---@enum LoadoutReminder.REMINDER_TYPES
LoadoutReminder.CONST.REMINDER_TYPES = {
    EQUIP = 'EQUIP',
    TALENTS = 'TALENTS',
    ADDONS = 'ADDONS',
}

---@enum LoadoutReminder.Raids
LoadoutReminder.CONST.RAIDS = {
    AMIRDRASSIL = 'AMIRDRASSIL',
    ABERRUS = 'ABERRUS',
}

--- List: https://wowpedia.fandom.com/wiki/InstanceID
LoadoutReminder.CONST.INSTANCE_IDS = {
    [2569] = 'ABERRUS',
    [2549] = 'AMIRDRASSIL'
}