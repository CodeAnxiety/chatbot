local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local DEFAULTS = {
    global = {
        allow_aliases = true,
        debug_mode = false,
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
                Addon.db.global.allow_aliases = value and true
                Addon:SetupCommands()
            end,
            get = function(info) return
                Addon.db.global.allow_aliases and true
            end
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


    local toggle_order = 1
    local module_order = 1

    for name, module in Addon:IterateModules() do
        -- add option to toggle the module
        options.args[name.."_toggle"] = {
            type = "toggle",
            name = module.name,
            order = toggle_order,
            desc = module.description or format(L["Enable the %s module."], name),
            get = function(_)
                return Addon:GetModuleEnabled(name)
            end,
            set = function(_, value)
                local enabled = Addon:SetModuleEnabled(name, value)
                Addon:ToggleModule(name, module, enabled)
            end,
        }
        toggle_order = toggle_order + 1

        local module_options = {
            type = "group",
            name = module.name,
            desc = module.description,
            disabled = function()
                return not Addon:GetModuleEnabled(name)
            end,
            args = {
                module_description = {
                    type = "description",
                    fontSize = "medium",
                    name = module.description .. "\n\n",
                    order = 1,
                },
            },
        }

        local include_module = false
        if module["Commands"] then
            include_module = true
        end
        if module["Aliases"] then
            include_module = true
        end

        -- populate with any module specific options
        local option_order = 2
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

local COMMANDS_START = 10000
local COMMANDS_END = 19999
local ALIASES_START = 20000
local ALIASES_END = 29999

local function HasCommandsVisible(args)
    for _, options in pairs(args) do
        if options.order > COMMANDS_START and options.order < COMMANDS_END then
            if not options.hidden() then
                return true
            end
        end
    end
    return false
end

local function HasAliasesVisible(args)
    for _, options in pairs(args) do
        if options.order > ALIASES_START and options.order < ALIASES_END then
            if not options.hidden() then
                return true
            end
        end
    end
    return false
end

local function BuildCommands(order)
    local options = {
        type = "group",
        name = L["Commands"],
        args = {},
        order = order,
    }
    order = order + 1

    local commands = {}
    local command_names = {}

    local aliases = {}
    local alias_names = {}

    for module_name, module in Addon:IterateModules() do
        if module["Commands"] then
            for command_name in pairs(module:Commands()) do
                table.insert(command_names, command_name)
                commands[command_name] = {
                    type = "description",
                    name = L[module_name.."__"..command_name],
                    hidden = function ()
                        return not Addon:GetModuleEnabled(module_name)
                    end
                }
            end
        end
        if module["Aliases"] then
            for alias_name in pairs(module:Aliases()) do
                table.insert(alias_names, alias_name)
                aliases[alias_name] = {
                    type = "description",
                    name = L[module_name.."__"..alias_name],
                    hidden = function ()
                        return not (Addon.db.global.allow_aliases and Addon:GetModuleEnabled(module_name))
                    end
                }
            end
        end
    end

    if commands then
        options.args.commands_header = {
            type = "header",
            name = L["Commands"],
            order = COMMANDS_START,
            hidden = function ()
                return not HasCommandsVisible(options.args)
            end
        }
        options.args.commands_separator = {
            type = "description",
            name = "\n",
            order = COMMANDS_END,
            hidden = function ()
                return not HasCommandsVisible(options.args)
            end
        }

        table.sort(command_names)

        local local_order = COMMANDS_START + 1
        for _, command_name in pairs(command_names) do
            commands[command_name].order = local_order
            local_order = local_order + 1
            options.args[command_name] = commands[command_name]
        end
    end

    if aliases then
        options.args.aliases_header = {
            type = "header",
            name = L["Aliases"],
            order = ALIASES_START,
            hidden = function ()
                return not (Addon.db.global.allow_aliases and HasAliasesVisible(options.args))
            end
        }
        options.args.aliases_separator = {
            type = "description",
            name = "\n",
            order = ALIASES_END,
            hidden = function ()
                return not HasCommandsVisible(options.args)
            end
        }

        table.sort(alias_names)

        local local_order = ALIASES_START + 1
        for _, alias_name in pairs(alias_names) do
            aliases[alias_name].order = local_order
            local_order = local_order + 1
            options.args[alias_name] = aliases[alias_name]
        end
    end

    options.hidden = function ()
        return not (HasCommandsVisible(options.args) or HasAliasesVisible(options.args))
    end

    return options, order
end

local function PopulateModuleCommands()
    for module_name, module in Addon:IterateModules() do
        if module["Commands"] then
            OPTIONS.args.modules.args[module_name].args.commands_header = OPTIONS.args.commands.args.commands_header
            OPTIONS.args.modules.args[module_name].args.commands_separator = OPTIONS.args.commands.args.commands_separator
            for command_name in pairs(module:Commands()) do
                OPTIONS.args.modules.args[module_name].args[command_name] = OPTIONS.args.commands.args[command_name]
            end
        end
        if module["Aliases"] then
            OPTIONS.args.modules.args[module_name].args.aliases_header = OPTIONS.args.commands.args.aliases_header
            OPTIONS.args.modules.args[module_name].args.aliases_separator = OPTIONS.args.commands.args.aliases_separator
            for alias_name in pairs(module:Aliases()) do
                OPTIONS.args.modules.args[module_name].args[alias_name] = OPTIONS.args.commands.args[alias_name]
            end
        end
    end
end

local function BuildOptionsTable()
    local order = 1
    OPTIONS.args.profiles, order = BuildProfileOptions(order)
    OPTIONS.args.modules, order = BuildModulesOptions(order)
    OPTIONS.args.commands, order = BuildCommands(order)
    PopulateModuleCommands()
    return order
end

function Addon:SetupOptions(register)
    if register then
        self.db = AceDB:New("ChatbotDB", DEFAULTS, true)
        self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

        AceConfig:RegisterOptionsTable(AddonName, OPTIONS)
        self.dbFrame = AceConfigDialog:AddToBlizOptions(AddonName, self.name);

        self:RegisterChatCommand("chatbot", "ShowOptions")
    end

    BuildOptionsTable()
end

function Addon:ShowOptions()
    if not AceConfigDialog.OpenFrames[AddonName] then
        AceConfigDialog:Open(AddonName)
    else
        AceConfigDialog:Close(AddonName)
    end
end

function Addon:OnProfileChanged()
    self:DisableAllModules(true)
    self:EnableAllModules()
    self:SetupOptions()
    self:SetupCommands()
    collectgarbage('collect');
end