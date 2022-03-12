local AceLocale = LibStub:GetLibrary("AceLocale-3.0")

local L = AceLocale:NewLocale("Chatbot", "enUS", true, true)
if not L then return end

local B = "|cff00c0f0" -- bold
local C = "|cff00f0c0" -- command
local P = "|cff00c080" -- parameter
local O = "|cff808080" -- optional
local H = "|cffb060b0" -- help
local R = "|r"         -- reset
local W = "|cfff0c000" -- warning

-- Shared
L["Chatbot"] = "Chatbot "..B.."9000"..R

-- Core.lua
L["Available Aliases"] = true
L["Available Commands"] = true
L["Configure which modules should be enabled."] = true
L["Debug Mode"] = true
L["Debug:"] = O.."Debug"..R..":"
L["Determines whether or not to chat message should actually be sent."] = true
L["Determines whether or not to print debug messages."] = true
L["Enable the %s module."] = "Enable the "..B.."%s"..R.." module."
L["Modules"] = true
L["Options"] = true
L["Test Mode"] = true
L["Usage:"] = H.."Usage"..R..":"
L["Warning:"] = W.."Warning"..R..":"

-- Languages.lua
L["Could not upsert macro: %s"] = true
L["Cycle Language"] = true
L["Determines whether the 'Cycle Language' macro should be created/updated when changing languages."] = true
L["Languages"] = true
L["Language Macro"] = true
L["Now speaking %s."] = "Now speaking "..B.."%s"..R.."."
L["You don't know how to speak %s."] = "You don't know how to speak "..B.."%s"..R.."."

L["Languages__set_language"] = "/"..C.."set_language"..R..O.." [name]"..R.." - Sets your chat language to the specified language."..R
L["Languages__cycle_language"] = "/"..C.."cycle_language"..R.." - Cycles between the languages you can speak."..R

L["LANGUAGES_MODULE_INFO"] = "The "..B.."Languages"..R.." module contains functionality to help you switch in-game languages easily."

-- Random.lua
L["Random"] = true

L["Random__random_chat"] = "/"..C.."random_chat"..R..P.." (message"..O.."[; ...]"..R..")"..R
    .." - Chooses a chat message to randomly say."..R
L["Random__random_emote"] = "/"..C.."random_emote"..R..P.." (emote"..O.."[; ...]"..R..")"..R
    .." - Chooses a chat emote to randomly play."..R
L["Random__rc"] = "/"..C.."rc"..R.." - Alias for the /"..C.."random_chat"..R.." command."..R
L["Random__re"] = "/"..C.."re"..R.." - Alias for the /"..C.."random_emote"..R.." command."..R

L["RANDOM_MODULE_INFO"] = "The "..B.."Random"..R.." module includes commands that allow you to randomize your chat macros."
