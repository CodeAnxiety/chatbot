local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

---
--- Returns whether the named module is configured to be enabled.
---
--- @param name string The name of the module.
--- @return boolean True if the module is configured to be enabled.
---
function Addon:ShouldModuleBeEnabled(name)
    Addon.Assert(type(name) == "string", "name must be a string")

    return self.db.profile.modules[name] and true
end

---
--- Sets whether the named module is configured to be enabled.
---
--- @param name string The name of the module.
--- @param enabled boolean True if the module should be configured to be enabled.
---
function Addon:SetShouldModuleBeEnabled(name, enabled)
    Addon.Assert(type(name) == "string", "name must be a string")

    self.db.profile.modules[name] = enabled and true
    return self.db.profile.modules[name]
end

---
--- Enables or disables the named module.
---
--- @param name string The name of the module.
--- @param enabled boolean|nil Whether the module should be enabled, or the module's configured enable state if nil.
---
function Addon:ToggleModule(name, module, enabled)
    Addon.TraceF("Addon:ToggleModule(%s, %s)", name, enabled ~= nil and tostring(enabled) or "nil")
    Addon.Assert(type(name) == "string", "name must be a string")
    Addon.Assert(module == nil or type(module) == "table", "module must be a table or nil")
    Addon.Assert(enabled == nil or type(enabled) == "boolean", "enabled must be a boolean or nil")

    if enabled == nil then
        enabled = not self:ShouldModuleBeEnabled(name)
    end

    if enabled then
        self:EnableNamedModule(name, module)
    else
        self:DisableNamedModule(name, module)
    end
end

---
--- Enables all modules if they are configured to be enabled.
---
function Addon:EnableAllModules()
    Addon.Trace("Addon:EnableAllModules")

    for name, module in self:IterateModules() do
        if self:ShouldModuleBeEnabled(name) then
            self:EnableNamedModule(name, module)
        end
    end
end

---
--- Enables the named module reguardless of its configured enabled state.
---
--- @param name string The name of the module.
--- @param module table|nil The module object.
---
function Addon:EnableNamedModule(name, module)
    Addon.TraceF("Addon:EnableNamedModule(%s)", name)
    Addon.Assert(type(name) == "string", "name must be a string")

    if module == nil then
        module = self:GetModule(name)
        if (module == nil) then return end
    end

    if not module:IsEnabled() then
        module:Enable()
    end

    self:SetupModuleCommands(name, module, true)
end

---
--- Disables all modules reguardless of their configured enabled state.
---
function Addon:DisableAllModules()
    Addon.Trace("Addon:DisableAllModules")

    for name, module in self:IterateModules() do
        self:DisableNamedModule(name, module)
    end
end

---
--- Disabled the named module reguardless of its configured enabled state.
---
--- @param name string The name of the module.
--- @param module table|nil The module object.
---
function Addon:DisableNamedModule(name, module)
    Addon.TraceF("Addon:DisableNamedModule(%s)", name)
    Addon.Assert(type(name) == "string", "name must be a string")
    Addon.Assert(module == nil or type(module) == "table", "module must be a table or nil")

    if module == nil then
        module = self:GetModule(name)
        if (module == nil) then return end
    end

    if module:IsEnabled() then
        module:Disable()
    end

    self:SetupModuleCommands(name, module, false)
end