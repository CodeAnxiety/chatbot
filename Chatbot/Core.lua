local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)


Addon = LibStub("AceAddon-3.0"):NewAddon(Addon, AddonName, "AceConsole-3.0")
Addon.name = L["Chatbot"]
Addon.description = L["Does your socializing for you!"]
Addon.version = GetAddOnMetadata(AddonName, "Version")
Addon.gameVersion = GetBuildInfo()
Addon.locale = GetLocale()

_G[AddonName] = Addon

function Addon:Warning(...)
    if self.db.global.debug_mode then
        self:Print(L["Warning:"], ...)
    end
end
function Addon:Warningf(...)
    if self.db.global.debug_mode then
        self:Print(L["Warning:"], format(...))
    end
end

function Addon:Debug(...)
    if self.db.global.debug_mode then
        self:Print(L["Debug:"], ...)
    end
end
function Addon:Debugf(...)
    if self.db.global.debug_mode then
        self:Print(L["Debug:"], format(...))
    end
end

function Addon:Dump(name, value, depth, maxDepth)
    if not self.db.global.debug_mode then
        return
    end

    name = name or "()"
    value = value ~= nil and value or "(nil)"
    depth = depth or 0
    maxDepth = maxDepth or 4

    if depth > maxDepth then return end

    if type(value) == "table" then
        local text = string.rep("  ", depth) .. name .. " <table>:"
        self:Debug(text)
        for k, v in pairs(value) do
            self:Dump("." .. k, v, depth + 1, maxDepth)
        end
        return
    end

    local valueType = type(value)
    local text =
        string.rep("  ", depth) .. name .. " <" .. valueType .. ">"
    if valueType == "boolean" then
        self:Debug(text .. " = " .. tostring(value))
    elseif valueType == "string" or valueType == "number" then
        self:Debug(text .. " = " .. value)
    else
        self:Debug(text)
    end
end

function Addon:OnInitialize()
    self:SetupOptions(true)
end

function Addon:OnEnable()
    self:EnableAllModules()
end

function Addon:OnDisable()
    self:DisableAllModules(false)
end
