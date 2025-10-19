local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local Module = Addon:NewModule("Languages", "AceConsole-3.0")
Module.name = L["Languages"]
Module.description = L["The Languages module contains functionality to help you switch in-game languages easily."]
Module.commands = {
    ["cycle_language"] = "CmdCycleLanguage",
    ["set_language"] = "CmdSetLanguage",
    ["reset_language"] = "CmdResetLanguage",
}
Module.aliases = {
    ["sl"] = "set_language",
    ["rsl"] = "reset_language",
}

local k_languageIcons = {
    ["Default"] = "inv_misc_questionmark",
    ["Common"] = "inv_misc_tournaments_banner_human",
    ["Darnassian"] = "inv_misc_tournaments_banner_nightelf",
    ["Draenei"] = "inv_misc_tournaments_banner_draenei",
    ["Dwarven"] = "inv_misc_tournaments_banner_dwarf",
    ["Gnomish"] = "inv_misc_tournaments_banner_gnome",
    ["Goblin"] = "ability_siege_engineer_pattern_recognition",
    ["Gutterspeak"] = "inv_misc_tournaments_banner_scourge",
    ["Orcish"] = "inv_misc_tournaments_banner_orc",
    ["Taur-ahe"] = "inv_misc_tournaments_banner_tauren",
    ["Thalassian"] = "inv_misc_tournaments_banner_bloodelf",
    ["Zandali"] = "inv_misc_tournaments_banner_troll",
    ["Shalassian"] = "inv_faction_hordewarfront_round_nightborne",
    ["Vulpera"] = "achievement_alliedrace_vulpera",
}

local k_defaults = {
    global = {
        use_macro = true,
        icons = Addon.Clone(k_languageIcons),
    },
    profile = {
        icons = {},
    },
    char = {
        icons = {},
    },
}

local s_options = {
    use_macro = {
        type = "toggle",
        name = L["Language Macro"],
        order = 1,
        desc = L["Determines whether the 'Cycle Language' macro should be created/updated when changing languages."],
        set = function(_, value)
            Module.db.global.use_macro = value
        end,
        get = function(_)
            return Module.db.global.use_macro
        end,
    }
}

local function GetLanguageIcon(name)
    return Module.db.char.icons[name]
        or Module.db.profile.icons[name]
        or Module.db.global.icons[name]
        or k_languageIcons[name]
        or k_languageIcons.Default
end

local function GetCurrentLanguageIndex()
    for index = 1, GetNumLanguages(), 1 do
        local _, id = GetLanguageByIndex(index)
        if id == DEFAULT_CHAT_FRAME.editBox.languageID then
            return index
        end
    end
    return 1
end

local function SetCurrentLanguageIndex(index, silent)
    local name, id = GetLanguageByIndex(index)
    if name == nil then
        index = 1
        name, id = GetLanguageByIndex(1)
    end

    if DEFAULT_CHAT_FRAME.editBox.languageID == id then
        return
    end

    DEFAULT_CHAT_FRAME.editBox.languageID = id

    if Module.db.global.use_macro then
        local icon = GetLanguageIcon(name)
        Addon.UpsertMacro(L["Cycle Language"], icon, "/cycle_language")
    end

    if not silent then
        Addon:Printf(L["Now speaking %s."], name)
    end
end

if not string["starts"] then
    function string.starts(input, match)
        return string.sub(input, 1, string.len(match)) == match
    end
end

function Module:Options()
    return s_options
end

function Module:OnInitialize()
    Addon.TraceF("Module[%s]:OnInitialize", self.name)

    self.db = Addon.db:RegisterNamespace("Languages", k_defaults)
end

function Module:OnEnable()
    Addon.TraceF("Module[%s]:OnEnable", self.name)

    SetCurrentLanguageIndex(GetCurrentLanguageIndex(), true)
end

function Module:OnDisable()
    Addon.TraceF("Module[%s]:OnDisable", self.name)

    SetCurrentLanguageIndex(1, true)
end

---
--- Usage: /cycle_language
---
function Module:CmdCycleLanguage(input)
    Addon.TraceF("Module[%s]:CmdCycleLanguage(%s)", self.name, input)

    if input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["Languages__cycle_language"])
        return
    end

    SetCurrentLanguageIndex(GetCurrentLanguageIndex() + 1, string.starts(input, "!"))
end

---
--- Usage: /set_language [name|index]
---
function Module:CmdSetLanguage(input)
    Addon.TraceF("Module[%s]:CmdSetLanguage(%s)", self.name, input)

    if input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["Languages__set_language"])
        return
    end

    local silent = string.starts(input, "!")
    if silent then
        input = string.sub(input, 2)
    end

    local match = string.lower(input)
    for index = 1, GetNumLanguages(), 1 do
        local name = GetLanguageByIndex(index)
        if string.lower(name) == match or tostring(index) == match then
            SetCurrentLanguageIndex(index, silent)
            return
        end
    end

    if not silent then
        Addon:Printf(L["You don't know how to speak %s."], input)
    end
end

---
--- Usage: /reset_language
---
function Module:CmdResetLanguage(input)
    Addon.TraceF("Module[%s]:CmdResetLanguage(%s)", self.name, input)

    if input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["Languages__reset_language"])
        return
    end

    SetCurrentLanguageIndex(1, string.starts(input, "!"))
end
