local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local Module = Addon:NewModule("Random", "AceConsole-3.0")
Module.name = L["Random"]
Module.description = L["The Random module includes commands that allow you to randomize your chat macros."]

local COMMANDS = {
    ["random_chat"] = "SendRandomChat",
    ["random_emote"] = "SendRandomEmote",
}
local ALIASES = {
    ["rc"] = "SendRandomChat",
    ["re"] = "SendRandomEmote",
}

function Module:Commands()
    return COMMANDS
end

function Module:Aliases()
    return ALIASES
end

local function StringTrim(input)
    input = tostring(input or "")
    input = strtrim(input, " \t\n")
    return input
end

local function StringSplit(input, separator)
    separator = tostring(separator or "\n")
    input = tostring(input or "") -- ensure valid string
    input = input:gsub(separator.."+", separator) -- remove empty lines in middle
    input = StringTrim(input)
    local results = {}
    for result in string.gmatch(input, "([^"..separator.."]+)") do
        result = StringTrim(result)
        if result ~= "" then
            table.insert(results, result)
        end
    end
    return results
end

local function GetSmartChatTarget()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		return "RAID"
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		return "PARTY"
	else
		return "SAY"
	end
end

local function GetRandomValue(values)
    return values[random(#values)]
end

function Module:SendRandomChat(input)
    if not input or input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["Random__random_chat"])
        return
    end
    local messages = StringSplit(input, ";")
    local message = GetRandomValue(messages)
    SendChatMessage(message, GetSmartChatTarget())
end

function Module:SendRandomEmote(input)
    if not input or input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["Random__random_emote"])
        return
    end
    local emotes = StringSplit(input, ";")
    local emote = GetRandomValue(emotes)
    DoEmote(emote, "none")
end
