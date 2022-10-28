local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local Module = Addon:NewModule("Random", "AceConsole-3.0")
Module.name = L["Random"]
Module.description = L["The Random module includes commands that allow you to randomize your chat macros."]
Module.commands = {
    ["random_message"] = "CmdRandomMessage",
    ["random_emote"] = "CmdRandomEmote",
}
Module.aliases = {
    ["rm"] = "random_message",
    ["re"] = "random_emote",
}

local function GetChatTarget()
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

---
--- Usage: /random_message message[; ...]
---
function Module:CmdRandomMessage(input)
    Addon.Trace("Module[%s]:CmdRandomMessage(%s)", self.name, input)

    if input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon.Info("Usage: %s", "$Usage:random_message")
        return
    end

    local messages = Addon.Split(input, ";")
    local message = Addon.Choose(messages)
    local target = GetChatTarget()

    SendChatMessage(message, target, DEFAULT_CHAT_FRAME.editBox.languageID)
end

---
--- Usage: /random_emote emote[; ...]
---
function Module:CmdRandomEmote(input)
    Addon.Trace("Module[%s]:CmdRandomEmote(%s)", self.name, input)

    if input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon.Info("Usage: %s", "$Usage:random_emote")
        return
    end

    local emotes = Addon.Split(input, ";")
    local emote = Addon.Choose(emotes)

    DoEmote(emote, "none")
end