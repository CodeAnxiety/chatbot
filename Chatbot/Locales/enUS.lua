local AddonName, Addon = ...

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(AddonName, "enUS", true, true)
if not L then return end

Addon.AliasPrefix = "cb_"

-- TODO: Figure out how to make this available in other files.
local function S(text)
    text = text:gsub("<b>", "|cff00c0f0") -- Bold
    text = text:gsub("<c>", "|cff00f0c0") -- Commands
    text = text:gsub("<p>", "|cff00c080") -- Parameters
    text = text:gsub("<o>", "|cff808080") -- Optional parameters
    text = text:gsub("<h>", "|cffb060b0") -- Help text
    text = text:gsub("<w>", "|cfff0c000") -- Warnings
    text = text:gsub("</>", "|r")         -- Reset
    return text
end

-- Text
L["Aliases"] = true
L["Chatbot"] = S("Chatbot <b>9000</>")
L["Commands"] = true
L["Configure which modules should be enabled."] = true
L["Could not upsert macro %s."] = S("Could not upsert macro <b>%s</>.")
L["Cycle Language"] = true
L["Determines whether or not command aliases are prefixed with _."] = S(
"Determines whether or not command aliases are prefixed with <b>" .. Addon.AliasPrefix .. "_</>.")
L["Determines whether or not to chat message should actually be sent."] = true
L["Determines whether or not to print debug messages."] = true
L["Determines whether the 'Cycle Language' macro should be created/updated when changing languages."] = true
L["Does your socializing for you!"] = true
L["Enable the %s module."] = S("Enable the <b>%s</> module.")
L["Language Macro"] = true
L["Languages"] = true
L["Modules"] = true
L["Now speaking %s."] = S("Now speaking <b>%s</>.")
L["Options"] = true
L["Prefix Aliases"] = true
L["Random"] = true
L["The Languages module contains functionality to help you switch in-game languages easily."] = S(
"The <b>Languages</> module contains functionality to help you switch in-game languages easily.")
L["The Random module includes commands that allow you to randomize your chat macros."] = S(
"The <b>Random</> module includes commands that allow you to randomize your chat macros.")
L["Usage:"] = S("<h>Usage</>:")
L["You don't know how to speak %s."] = S("You don't know how to speak <b>%s</>.")
L["/%s%s -> "] = S("/<o>%s</><c>%s</> -> ")

-- Commands
L["Languages.cycle_language"] = S("/<c>cycle_language</> - Cycles between the languages you can speak.</>")
L["Languages.set_language"] = S(
"/<c>set_language</> <o>[name]</> - Sets your chat language to the specified language.</>")
L["Languages.reset_language"] = S("/<c>reset_language</> - Resets your chat language to the default language.</>")
L["Random.random_message"] = S(
"/<c>random_message</> <p>(message<o>[; ...])</> - Chooses a chat message to randomly say.</>")
L["Random.random_emote"] = S("/<c>random_emote</> <p>(emote<o>[; ...])</> - Chooses a chat emote to randomly play.</>")