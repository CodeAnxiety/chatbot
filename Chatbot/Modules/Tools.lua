local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local Module = Addon:NewModule("Tools", "AceConsole-3.0")
Module.name = L["Tools"]
Module.description = L["The Tools contains miscellaneous tools."]
Module.commands = {
    ["clear_chat"] = "CmdClearChat",
    ["find_binding"] = "CmdFindBinding",
}
Module.aliases = {
    ["cls"] = "clear_chat",
}


function Module:CmdClearChat()
    if SELECTED_CHAT_FRAME ~= nil then
        SELECTED_CHAT_FRAME:Clear()
    else
        ChatFrame1:Clear()
    end
end

function Module:CmdFindBinding(input)
    local found = false
    for i = 1, GetNumBindings() do
        local result = { GetBinding(i) }
        for _, value in ipairs(result) do
            if string.match(tostring(value) or '', input) then
                Addon.Info("Found %s: %s", input, table.concat(result))
                found = true
            end
        end
    end
    if found == false then
        Addon.Info("Binding not found: %s", input)
    end
end