_, LoadoutReminder = ...

LoadoutReminder.CONST = {}

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
}

-- TODO: Gather data
LoadoutReminder.CONST.BOSS_ID_MAP = {
    -- Amirdrassil
    [209333] = 'AMIRDRASSIL_GNARLROOT',
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
}

LoadoutReminder.CONST.ADDON_LIST_ADDONS = {
    BETTER_ADDON_LIST = "BetterAddonList",
    ADDON_CONTROL_PANEL = "AddonControlPanel",
}