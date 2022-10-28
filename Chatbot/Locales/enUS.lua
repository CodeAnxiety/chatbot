local AddonName, Addon = ...

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(AddonName, "enUS", true, true)
if not L then return end

Addon.AliasPrefix = "cb_"

local function S(...) return StyleText(...) end

local kAddonName = S("<c>Chat<o>bot <b>9000</>")
local kAddonShortName = S("<c>C<o>B<b>9K</>")

-- Logging
L["Log Trace: "] = kAddonShortName .. S(": <#666>Trace:</> ")
L["Log Debug: "] = kAddonShortName .. S(": <#888>Debug:</> ")
L["Log Info: "] = kAddonShortName .. ": "
L["Log Warning: "] = kAddonShortName .. S(": <#cc4>Warning:</> ")
L["Log Error: "] = kAddonName .. S(": <#c44>Error:</> ")
L["Log Assert: "] = kAddonShortName .. S(": <#c00>Assert:</> ")

-- Text
L["Aliases"] = true
L["Chatbot"] = kAddonName
L["Chatbot:Short"] = kAddonShortName
L["Commands"] = true
L["Configure which modules should be enabled."] = true
L["Could not upsert macro %s."] = S("Could not upsert macro <b>s</>.")
L["Cycle Language"] = true
L["Determines whether or not command aliases are prefixed with _."] = S("Determines whether or not command aliases are prefixed with '<b>"
    .. Addon.AliasPrefix .. "_</>'.")
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
L["The Languages module contains functionality to help you switch in-game languages easily."] = S("The <b>Languages</> module contains functionality to help you switch in-game languages easily.")
L["The Random module includes commands that allow you to randomize your chat macros."] = S("The <b>Random</> module includes commands that allow you to randomize your chat macros.")
L["Usage: %s"] = S("<h>Usage</>: %s")
L["You don't know how to speak %s."] = S("You don't know how to speak <b>%s</>.")
L["/%s%s -> %s"] = S("/<o>%s</><c>%s</> -> <c>%s</>")

-- Command Help
L["Usage:cycle_language"] = S("/<c>cycle_language</> - Cycles between the languages you can speak.")
L["Usage:set_language"] = S("/<c>set_language</> <o>[name]</> - Sets your chat language to the specified language.")
L["Usage:reset_language"] = S("/<c>reset_language</> - Resets your chat language to the default language.")
L["Usage:random_message"] = S("/<c>random_message</> <p>(message<o>[; ...]</>)</> - Chooses a chat message to randomly say.")
L["Usage:random_emote"] = S("/<c>random_emote</> <p>(emote<o>[; ...]</>)</> - Chooses a chat emote to randomly play.")