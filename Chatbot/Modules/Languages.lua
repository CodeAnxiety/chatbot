local _, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(Addon.namespace)

local Module = Addon:NewModule("Languages", "AceConsole-3.0")
Module.name = L["Languages"]
Module.namespace = "Languages"

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

local DEFAULTS = {
    global = {
        languages = {
            usage_macro = true,
        },
    }
}

local OPTIONS, COMMANDS

local function UpsertMacro(name, icon, body, perCharacter)
    local index = GetMacroIndexByName(name)
    local id
    if index ~= nil and index ~= 0 then
        id = EditMacro(index, name, icon, body, 1, perCharacter and 1 or nil)
    else
        id = CreateMacro(name, icon, body, perCharacter and 1 or nil)
    end
    if id == nil then
        Addon:Debug(format(L["Could not upsert macro: %s"], name))
    end
end

function Module:Info()
    return L["LANGUAGES_MODULE_INFO"]
end

function Module:Options()
    if OPTIONS == nil then
        OPTIONS = {
            use_macro = {
                type = "toggle",
                name = L["Language Macro"],
                order = 1,
                desc = L["Determines whether the 'Cycle Language' macro should be created/updated when changing languages."],
                set = function(info, value)
                    self.db.global.languages.use_macro = value
                end,
                get = function(info)
                    return self.db.global.languages.use_macro
                end,
            }
        }
    end
    return OPTIONS
end

function Module:Commands()
    if COMMANDS == nil then
        COMMANDS = {
            ["cycle_language"] = "CycleLanguage",
            ["set_language"] = "SetLanguage",
        }
    end
    return COMMANDS
end

function Module:OnInitialize()
    self.db = self.db or Addon.db:RegisterNamespace(Module.namespace, DEFAULTS)
end


function Module:OnEnable()
    self:SetCurrentLanguageIndex(self:GetCurrentLanguageIndex(), true)

    Addon:Debug(self.name, "module is enabled.")
end

function Module:OnDisable()
    Addon:Debug(self.name, "module is disabled.")
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

function Module:SetCurrentLanguageIndex(index, silent)
    local name, id = GetLanguageByIndex(index)
    if name == nil then
        index = 1
        name, id = GetLanguageByIndex(1)
    end

    DEFAULT_CHAT_FRAME.editBox.languageID = id

    if self.db.global.languages.use_macro then
        local icon = LANGUAGES[name] or LANGUAGES["Default"]
        UpsertMacro(L["Cycle Language"], icon, "/cycle_language")
    end

    if silent ~= true then
        Addon:Print(format(L["Now speaking |cff88ff44%s|r."], name))
    end
end

function Module:CycleLanguage(input)
    if input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["CYCLE_LANGUAGE_USAGE"])
        return
    end
    self:SetCurrentLanguageIndex(self:GetCurrentLanguageIndex() + 1)
end

function Module:SetLanguage(input)
    if not input or input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["SET_LANGUAGE_USAGE"])
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
    Addon:Print(format(L["You don't know how to speak |cff88ff44%s|r."], input))
end
