local _, Addon = ...


function Addon:SetupCommands()
    for name, module in Addon:IterateModules() do
        self:SetupModuleCommands(name, module)
    end
end

function Addon:SetupModuleCommands(name, module, enabled)
    assert(type(name) == "string")

    if module == nil then
        module = self:GetModule(name)
        if module == nil then return end
    end

    if enabled == nil then
        enabled = Addon:GetModuleEnabled(name)
    end

    if module["Commands"] then
        for command_name, command_function in pairs(module:Commands()) do
            if enabled then
                module:RegisterChatCommand(command_name, command_function)
            else
                module:UnegisterChatCommand(command_name, command_function)
            end
        end
    end

    if module["Aliases"] then
        for alias_name, alias_function in pairs(module:Aliases()) do
            if self.db.global.allow_aliases and enabled then
                module:RegisterChatCommand(alias_name, alias_function)
            else
                module:UnregisterChatCommand(alias_name, alias_function)
            end
        end
    end
end
