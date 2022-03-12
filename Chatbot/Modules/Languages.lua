local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local Module = Addon:NewModule("Languages", "AceConsole-3.0")
Module.name = L["Languages"]
Module.description = L["The Languages module contains functionality to help you switch in-game languages easily."]

local LANGUAGES = {
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

local function ShallowCopy(tab)
    local result = {}
    for key, value in pairs(tab) do
        result[key] = value
    end
    return result
end

local DEFAULTS = {
    global = {
        usage_macro = true,
        icons = ShallowCopy(LANGUAGES),
    },
    profile = {
        icons = {},
    },
    char = {
        icons = {},
    },
}

local OPTIONS = {
    use_macro = {
        type = "toggle",
        name = L["Language Macro"],
        order = 1,
        desc = L["Determines whether the 'Cycle Language' macro should be created/updated when changing languages."],
        set = function(info, value)
            Module.db.global.use_macro = value
        end,
        get = function(info)
            return Module.db.global.use_macro
        end,
    }
}

local COMMANDS = {
    ["cycle_language"] = "CycleLanguage",
    ["set_language"] = "SetLanguage",
}
local ALIASES = {
    ["sl"] = "SetLanguage",
}

local function GetLanguageIcon(name)
    return Module.db.char.icons[name]
        or Module.db.profile.icons[name]
        or Module.db.global.icons[name]
        or LANGUAGES[name]
        or LANGUAGES.Default
end

local function UpsertMacro(name, icon, body, perCharacter)
    local index = GetMacroIndexByName(name)
    local id
    if index ~= nil and index ~= 0 then
        id = EditMacro(index, name, icon, body)
    else
        id = CreateMacro(name, icon, body, perCharacter)
    end
    if id == nil then
        Addon:Debugf(L["Could not upsert macro: %s"], name)
    end
end

function Module:Options()
    return OPTIONS
end

function Module:Commands()
    return COMMANDS
end

function Module:Aliases()
    return ALIASES
end

function Module:OnInitialize()
    self.db = self.db or Addon.db:RegisterNamespace("Languages", DEFAULTS)
end

function Module:OnEnable()
    self:SetCurrentLanguageIndex(self:GetCurrentLanguageIndex(), true)
end

function Module:OnDisable()
    self:SetCurrentLanguageIndex(1)
end

function Module:GetCurrentLanguageIndex()
    for index = 1, GetNumLanguages(), 1 do
        local _, id = GetLanguageByIndex(index)
        if id == DEFAULT_CHAT_FRAME.editBox.languageID then
            return index
        end
    end
    return 1
end

function Module:GetLanguageIndex(name)
    for index = 1, GetNumLanguages(), 1 do
        local language, id = GetLanguageByIndex(index)
        if language == name then
            return index
        end
    end
end

function Module:SetCurrentLanguageIndex(index, silent)
    local name, id = GetLanguageByIndex(index)
    if name == nil then
        index = 1
        name, id = GetLanguageByIndex(1)
    end

    DEFAULT_CHAT_FRAME.editBox.languageID = id

    if self.db.global.use_macro then
        local icon = GetLanguageIcon(name)
        UpsertMacro(L["Cycle Language"], icon, "/cycle_language")
    end

    if silent ~= true then
        Addon:Printf(L["Now speaking %s."], name)
    end
end

function Module:CycleLanguage(input)
    if input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["Languages__cycle_language"])
        return
    end
    self:SetCurrentLanguageIndex(self:GetCurrentLanguageIndex() + 1)
end

function Module:SetLanguage(input)
    if not input or input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["Languages__set_language"])
        return
    end
    local match = string.lower(input)
    for index = 1, GetNumLanguages(), 1 do
        local name, id = GetLanguageByIndex(index)
        if index == match or string.lower(name) == match then
            self:SetCurrentLanguageIndex(index)
            return
        end
    end
    Addon:Printf(L["You don't know how to speak %s."], input)
end
