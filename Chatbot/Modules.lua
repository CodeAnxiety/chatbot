local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

function Addon:GetModuleEnabled(name)
    assert(type(name) == "string")

    return self.db.profile.modules[name] and true
end

function Addon:SetModuleEnabled(name, enabled)
    assert(type(name) == "string")

    self.db.profile.modules[name] = enabled and true
    return self.db.profile.modules[name]
end

function Addon:GetModule(name)
    assert(type(name) == "string")

    for module_name, module in self:IterateModules() do
        if module_name == name then
            return module
        end
    end

    self:Warningf(L["Could not find module: %s"], name)
end

function Addon:ToggleModule(name, enabled)
    assert(type(name) == "string")

    if enabled == nil then
        enabled = not self:GetModuleEnabled(name)
    end
    if enabled then
        self:EnableNamedModule(name)
    else
        self:DisableNamedModule(name)
    end
end

function Addon:EnableAllModules()
    for name, module in self:IterateModules() do
        if self:GetModuleEnabled(name) then
            self:EnableNamedModule(name, module)
        end
    end
end

function Addon:EnableNamedModule(name, module)
    assert(type(name) == "string")

    if module == nil then
        module = self:GetModule(name)
        if (module == nil) then return end
    end

    if not module:IsEnabled() then
        module:Enable()
    end

    self:SetupModuleCommands(name, module, true)
end

function Addon:DisableAllModules()
    for name, module in self:IterateModules() do
        self:DisableNamedModule(name, module)
    end
end

function Addon:DisableNamedModule(name, module)
    assert(type(name) == "string")

    if module == nil then
        module = self:GetModule(name)
        if (module == nil) then return end
    end

    if module:IsEnabled() then
        module:Disable()
    end

    self:SetupModuleCommands(name, module, false)
end