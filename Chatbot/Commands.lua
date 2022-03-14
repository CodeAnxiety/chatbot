local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local AceConsole = LibStub("AceConsole-3.0")

local function RegisterCommand(module, name, callbackName)
    Addon.Tracef("RegisterCommand(%s, %s, %s)", module.name, name, callbackName)

    if not AceConsole.commands[name] then
        module:RegisterChatCommand(name, callbackName)
        Addon.Debugf("Command /%s is now registered to %s.", name, callbackName)
    else
        Addon.Tracef("Command /%s is was already registered to %s.", name, callbackName)
    end
end

local function UnregisterCommand(module, name, callbackName)
    Addon.Tracef("UnregisterCommand(%s, %s, %s)", module.name, name, callbackName)

    if AceConsole.commands[name] then
        module:UnregisterChatCommand(name, callbackName)
        Addon.Debugf("Command /%s is now unregistered from %s.", name, callbackName)
    else
        Addon.Tracef("Command /%s is was already unregistered from %s.", name, callbackName)
    end
end

local function ToggleCommand(module, name, callbackName, enabled)
    Addon.Tracef("ToggleCommand(%s, %s, %s, %s)", module.name, name, callbackName, tostring(enabled or "nil"))

    if enabled then
        RegisterCommand(module, name, callbackName)
    else
        UnregisterCommand(module, name, callbackName)
    end
end

local function GetAliasNames(name)
    if Addon.db.global.prefixAliases then
        return Addon.AliasPrefix .. name, name
    else
        return name, Addon.AliasPrefix .. name
    end
end

local function ToggleAlias(module, name, callbackName, enabled)
    Addon.Tracef("ToggleAlias(%s, %s, %s, %s)", module.name, name, callbackName, tostring(enabled))

    local primaryName, altName = GetAliasNames(name)

    UnregisterCommand(module, altName, callbackName)

    if enabled and Addon.db.global.allowAliases then
        RegisterCommand(module, primaryName, callbackName)
    else
        RegisterCommand(module, primaryName, callbackName)
    end
end

---
--- Sets up commands for each module based on the module's enabled state.
---
function Addon:SetupCommands()
    Addon.Trace("Addon:SetupCommands")

    for name, module in Addon:IterateModules() do
        self:SetupModuleCommands(name, module, module:IsEnabled())
    end
end

---
--- Registers or unregisters commands and aliases for a mdoule.
---
--- @param name string The name of the module.
--- @param module table|nil The module object.
--- @param enabled boolean|nil Whether the commands should be registered or not.
---
function Addon:SetupModuleCommands(name, module, enabled)
    Addon.Tracef("Addon:SetupModuleCommands(%s, %s, %s)", name, module ~= nil and module.name or "nil", tostring(enabled or "nil"))
    Addon.Assert(type(name) == "string", "name must be string")
    Addon.Assert(module == nil or type(module) == "table", "module must be a table or nil")
    Addon.Assert(enabled == nil or type(enabled) == "boolean", "enabled must be a boolean or nil")

    if module == nil then
        module = self:GetModule(name)
    end
    if module == nil or module.commands == nil then
        return -- nothing to do
    end

    if enabled == nil then
        enabled = Addon:ShouldModuleBeEnabled(name)
    end

    for commandName, callbackName in pairs(module.commands) do
        ToggleCommand(module, commandName, callbackName, enabled)
    end

    if module.aliases then
        for aliasName, commandName in pairs(module.aliases) do
            local callbackName = module.commands[commandName]
            ToggleAlias(module, aliasName, callbackName, enabled)
        end
    end
end

