local AddonName, _ = ...

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(AddonName, "enUS", true, true)
if not L then return end

-- TODO: Figure out how to make this available in other files.
local function S(text)
    text = text:gsub("|B", "|cff00c0f0") -- Bold
    text = text:gsub("|C", "|cff00f0c0") -- Commands
    text = text:gsub("|P", "|cff00c080") -- Parameters
    text = text:gsub("|O", "|cff808080") -- Optional parameters
    text = text:gsub("|H", "|cffb060b0") -- Help text
    text = text:gsub("|W", "|cfff0c000") -- Warnings
    return text
end

-- Text
L["Aliases"] = true
L["Chatbot"] = S("Chatbot |B9000|r")
L["Commands"] = true
L["Configure which modules should be enabled."] = true
L["Could not find module: %s"] = true
L["Could not upsert macro: %s"] = true
L["Cycle Language"] = true
L["Debug Mode"] = true
L["Debug:"] = S("|WDebug|r:")
L["Determines whether or not to chat message should actually be sent."] = true
L["Determines whether or not to print debug messages."] = true
L["Determines whether the 'Cycle Language' macro should be created/updated when changing languages."] = true
L["Disabling module: %s"] = true
L["Does your socializing for you!"] = true
L["Enable the %s module."] = S("Enable the |B%s|r module.")
L["Enabling module: %s"] = true
L["Initializing module: %s"] = true
L["Language Macro"] = true
L["Languages"] = true
L["Module was not initialized: %s"] = true
L["Modules"] = true
L["Now speaking %s."] = S("Now speaking |B%s|r.")
L["Options"] = true
L["Random"] = true
L["Test Mode"] = true
L["The Languages module contains functionality to help you switch in-game languages easily."] = S("The |BLanguages|r module contains functionality to help you switch in-game languages easily.")
L["The Random module includes commands that allow you to randomize your chat macros."] = S("The |BRandom|r module includes commands that allow you to randomize your chat macros.")
L["Usage:"] = S("|HUsage|r:")
L["Warning:"] = S("|WWarning|r:")
L["You don't know how to speak %s."] = S("You don't know how to speak |B%s|r.")

-- Commands
L["Languages__cycle_language"] = S("/|Ccycle_language|r - Cycles between the languages you can speak.|r")
L["Languages__set_language"] = S("/|Cset_language|r|O [name]|r - Sets your chat language to the specified language.|r")
L["Random__random_chat"] = S("/|Crandom_chat|r|P (message|O[; ...]|r)|r - Chooses a chat message to randomly say.|r")
L["Random__random_emote"] = S("/|Crandom_emote|r|P (emote|O[; ...]|r)|r - Chooses a chat emote to randomly play.|r")

-- Aliases
L["Random__rc"] = S("/|Crc|r - Alias for the /|Crandom_chat|r command.|r")
L["Random__re"] = S("/|Cre|r - Alias for the /|Crandom_emote|r command.|r")
L["Languages__sl"] = S("/|Csl|r - Alias for the /|Cset_language|r command.|r")
