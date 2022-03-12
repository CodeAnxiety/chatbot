local AddonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

Addon = LibStub("AceAddon-3.0"):NewAddon(Addon, AddonName, "AceConsole-3.0")
Addon.name = L["Chatbot"]
Addon.namespace = AddonName

_G[AddonName] = Addon

local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local DEFAULTS = {
    global = {
        debug_mode = false,
        test_mode = true,
        allow_aliases = true,
    },
    profile = {
        modules = {
            ["Languages"] = true,
            ["Random"] = true,
        },
    },
}

local OPTIONS = {
    name = Addon.name,
    handler = Addon,
    type = "group",
    args = {
        allow_aliases = {
            type = "toggle",
            name = L["Allow Aliases"],
            order = 1,
            desc = L["Determines whether or not command aliases are enabled."],
            set = function(info, value)
                Addon.db.global.allow_aliases = value
                Addon:SetupCommands()
            end,
            get = function(info) return Addon.db.global.allow_aliases end
        },
        test_mode = {
            type = "toggle",
            name = L["Test Mode"],
            order = 2,
            desc = L["Determines whether or not to chat message should actually be sent."],
            set = function(info, value) Addon.db.global.test_mode = value end,
            get = function(info) return Addon.db.global.test_mode end
        },
        debug_mode = {
            type = "toggle",
            name = L["Debug Mode"],
            order = 3,
            desc = L["Determines whether or not to print debug messages."],
            set = function(info, value)
                Addon.db.global.debug_mode = value and true
            end,
            get = function(info)
                return Addon.db.global.debug_mode and true
            end,
        },
    }
}

function Addon:Debug(...)
    if self.db.global.debug_mode then
        self:Print(L["Debug:"], ...)
    end
end

function Addon:Warning(...)
    if self.db.global.debug_mode then
        self:Print(L["Warning:"], ...)
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

local function BuildProfileOptions(order)
    local options = AceDBOptions:GetOptionsTable(Addon.db)
    options.order = order
    order = order + 1
    return options, order
end

local function BuildModulesOptions(order)
    local options = {
        type = "group",
        name = L["Modules"],
        desc = L["Configure which modules should be enabled."],
        args = {},
        order = order,
    }
    order = order + 1

    toggle_order = 1
    module_order = 1
    for name, module in Addon:IterateModules() do
        -- add option to toggle the module
        options.args[name.."_toggle"] = {
            type = "toggle",
            name = name,
            order = toggle_order,
            desc = module:Info() or format(L["Enable the %s module."], name),
            get = function(info)
                return Addon:GetModuleEnabled(name)
            end,
            set = function(info, value)
                local enabled = Addon:SetModuleEnabled(name, value)
                Addon:ToggleModule(module, enabled)
            end,
        }
        toggle_order = toggle_order + 1

        local include_module = false
        local module_options = {
            type = "group",
            name = module.name,
            desc = module:Info(),
            disabled = function()
                return not Addon:GetModuleEnabled(name)
            end,
            args = {
                intro = {
                    type = "description",
                    fontSize = "medium",
                    name = module:Info() .. "\n\n",
                    order = 1,
                },
            },
        }

        option_order = 2

        -- create section for the module's commands
        if module["Commands"] then
            local commands = {}
            for command in pairs(module:Commands()) do
                table.insert(commands, command)
            end
            table.sort(commands)

            help = ""
            for i = 1, #commands, 1 do
                if help ~= "" then help = help .. "\n\n" end
                help = help .. L[name.."__"..commands[i]]
            end

            module_options.args.commands_header = {
                type = "header",
                name = L["Available Commands"],
                order = option_order,
            }
            option_order = option_order + 1

            module_options.args.commands = {
                type = "description",
                name = help,
                order = option_order,
            }
            option_order = option_order + 1

            include_module = true
        end

        -- create section for the module's aliases
        if Addon.db.global.allow_aliases and module["Aliases"] then
            local aliases = {}
            for command in pairs(module:Aliases()) do
                table.insert(aliases, command)
            end
            table.sort(aliases)

            help = ""
            for i = 1, #aliases, 1 do
                if help ~= "" then help = help .. "\n\n" end
                help = help .. L[name.."__"..aliases[i]]
            end

            module_options.args.aliases_header = {
                type = "header",
                name = L["Available Aliases"],
                order = option_order,
            }
            option_order = option_order + 1

            module_options.args.aliases = {
                type = "description",
                name = help,
                order = option_order,
            }
            option_order = option_order + 1

            include_module = true
        end

        -- populate with any module specific options
        if module["Options"] then
            module_options.args.options_header = {
                type = "header",
                name = L["Options"],
                order = option_order,
            }
            option_order = option_order + 1

            for key, value in pairs(module:Options()) do
                module_options.args[key] = value
                if module_options.args[key].order ~= nil then
                    module_options.args[key].order = module_options.args[key].order + option_order
                else
                    module_options.args[key].order = option_order
                    option_order = option_order + 1
                end
            end

            include_module = true
        end

        -- if we found commands or options then add it to the last
        if include_module then
            module_options.order = module_order
            module_order = module_order + 1
            options.args[name] = module_options
        end
    end

    return options, order
end

local function BuildOptionsTable()
    order = 1
    OPTIONS.args.profiles, order = BuildProfileOptions(order)
    OPTIONS.args.modules, order = BuildModulesOptions(order)
end


local function Addon:SetupCommands()
    for name, module Addon:IterateModules() do
        self:SetupModuleCommands(name, module)
    end
end

local function Addon:SetupModuleCommands(name, module, enabled)
    assert(type(name) == "string")
    if module == nil then
        module = self:GetModule(name)
        assert(module ~= nil)
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

function Addon:OnInitialize()
    self.db = AceDB:New("ChatbotDB", DEFAULTS, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

    BuildOptionsTable()

    AceConfig:RegisterOptionsTable(self.namespace, OPTIONS, {self.namespace})
    self.dbFrame = AceConfigDialog:AddToBlizOptions(self.namespace, self.name);

    self:OnProfileChanged()
end

function Addon:OnEnable()
    self:RegisterChatCommand("chatbot", "ShowOptions")

    self:EnableAllModules()
end

function Addon:OnDisable()
    self:DisableAllModules(false)
end

function Addon:OnProfileChanged()
    self:Debug("Initializing modules.")

    self:DisableAllModules(true)
    self:EnableAllModules()

    BuildOptionsTable()

    collectgarbage('collect');
end

function Addon:ShowOptions()
    if not AceConfigDialog.OpenFrames[self.namespace] then
        AceConfigDialog:Open(self.namespace)
    else
        AceConfigDialog:Close(self.namespace)
    end
end

function Addon:GetModuleEnabled(module)
    if type(module) ~= "string" then
        module = module.name
    end
    return self.db.profile.modules[module] and true
end

function Addon:SetModuleEnabled(module, enabled)
    if type(module) ~= "string" then
        module = module.name
    end
    enabled = enabled and true
    self.db.profile.modules[module] = enabled
    return enabled
end

function Addon:GetModule(name)
    for module_name, module in self:IterateModules() do
        if module_name == name then
            return module
        end
    end
    self:Warning("Could not find module:", name)
end

function Addon:ToggleModule(module, enabled)
    if enabled == nil then
        enabled = not self:GetModuleEnabled(module)
    end
    if enabled then
        self:EnableModule(module)
    else
        self:DisableModule(module)
    end
end

function Addon:EnableAllModules(force)
    for name, module in self:IterateModules() do
        if force or self:GetModuleEnabled(name) then
            self:EnableModule(name, module)
        end
    end
end

function Addon:EnableModule(name, module)
    if module == nil then
        module = self:GetModule(name)
    end

    if module:IsEnabled() then return end
    self:Debug("Enabling module:", name)

    module:Enable()

    self:SetupModuleCommands(name, module, true)
end

function Addon:DisableAllModules(force)
    for name, module in self:IterateModules() do
        self:DisableModule(name, module)
    end
end

function Addon:DisableModule(name, module)
    if module == nil then
        module = self:GetModule(name)
    end

    if not module:IsEnabled() then return end
    self:Debug("Disabling module:", module.name)

    module:Disable()

    self:SetupModuleCommands(name, module, false)
end