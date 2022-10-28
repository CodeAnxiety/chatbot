local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

Addon = LibStub("AceAddon-3.0"):NewAddon(Addon, AddonName, "AceConsole-3.0")
Addon.name = L["Chatbot"]
Addon.description = L["Does your socializing for you!"]
Addon.version = GetAddOnMetadata(AddonName, "Version")
Addon.gameVersion = GetBuildInfo()
Addon.locale = GetLocale()

_G[AddonName] = Addon

function Addon:OnInitialize()
    Addon.Trace("Addon:OnInitialize")

    self:RegisterDB()
    self:SetupOptions()
end

function Addon:OnEnable()
    Addon.Trace("Addon:OnEnabled")

    self:EnableAllModules()
end

function Addon:OnDisable()
    Addon.Trace("Addon:OnDisable")

    self:DisableAllModules(false)
end