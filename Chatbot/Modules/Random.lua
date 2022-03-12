local _, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(Addon.namespace)

local Module = Addon:NewModule("Random", "AceConsole-3.0")
Module.name = L["Random"]
Module.namespace = "Random"

local OPTIONS, COMMANDS, ALIASES

function Module:Info()
    return L["RANDOM_MODULE_INFO"]
end

function Module:Commands()
    if COMMANDS == nil then
        COMMANDS = {
            ["random_chat"] = "SendRandomChatMessage",
            ["random_emote"] = "SendRandomEmote",
        }
    end
    return COMMANDS
end

function Module:Aliases()
    if ALIASES == nil then
        ALIASES = {
            ["rc"] = "SendRandomChatMessage",
            ["re"] = "SendRandomEmote",
        }
    end
    return ALIASES
end

function Module:OnEnable()
    Addon:Debug(self.name, "module is now enabled.")
end

function Module:OnDisable()
    Addon:Debug(self.name, "module is now disabled.")
end

local function StringTrim(input)
    input = tostring(input or "")
    input = strtrim(input, " ", "\t", "\n")
    return input
end

local function StringJoin(values, separator)
    separator = separator or "\n"
    if type(values) ~= "table" then values = {values} end
    result = strjoin(separator, unpack(values))
    return result
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

function Module:SendRandomChatMessage(input)
    if not input or input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["RANDOM_CHAT_USAGE"])
        return
    end
    local messages = StringSplit(input, "\n;")
    local message = GetRandomValue(messages)
    SendChatMessage(message, GetSmartChatTarget())
end

function Module:SendRandomEmote(input)
    if not input or input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon:Print(L["Usage:"], L["RANDOM_EMOTE_USAGE"])
        return
    end
    local emotes = StringSplit(input, "\n;")
    local emote = GetRandomValue(emotes)
    DoEmote(emote, "none")
end
