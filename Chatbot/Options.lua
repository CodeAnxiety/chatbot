local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local k_commandOrderStart = 10000
local k_commandOrderEnd = 19999
local k_aliasOrderStart = 20000
local k_aliasOrderEnd = 29999

local function IsCommandArg(options)
    -- exclude the header[order = k_commandOrderStart]
    -- exclude the footer[order = k_commandOrderEnd]
    return options["order"] ~= nil and options.order > k_commandOrderStart and options.order < k_commandOrderEnd
end

local function IsAliasArg(options)
    -- exclude the header[order = k_aliasOrderStart]
    -- exclude the footer[order = k_aliasOrderEnd]
    return options["order"] ~= nil and options.order > k_aliasOrderStart and options.order < k_aliasOrderEnd
end

local function AnyCommandsVisible(args)
    for _, options in pairs(args) do
        if IsCommandArg(options) and not options.hidden() then
            return true
        end
    end
    return false
end

local function AnyAliasesVisible(args)
    if not Addon.db.global.allow_aliases then return false end
    for _, options in pairs(args) do
        if IsAliasArg(options) and not options.hidden() then
            return true
        end
    end
    return false
end

local k_defaults = {
    global = {
        allowAliases = true,
        prefixAliases = true,
    },
    profile = {
        modules = {
            ["Languages"] = true,
            ["Random"] = true,
        },
    },
}

local s_options -- separated so embedded functions can reference it
s_options = {
    name = Addon.name,
    handler = Addon,
    type = "group",
    args = {
        modules = {
            type = "group",
            name = L["Modules"],
            desc = L["Configure which modules should be enabled."],
            args = {},
        },
        commands = {
            type = "group",
            name = L["Commands"],
            hidden = function()
                return not AnyCommandsVisible(s_options.args.commands.args)
            end,
            args = {
                headerOptions = {
                    type = "header",
                    name = L["Options"],
                    order = 1,
                },
                allowAliases = {
                    type = "toggle",
                    name = L["Allow Aliases"],
                    order = 2,
                    desc = L["Determines whether or not command aliases are enabled."],
                    set = function(_, value)
                        Addon.db.global.allowAliases = value and true
                        Addon:SetupCommands()
                    end,
                    get = function(_)
                        return
                            Addon.db.global.allowAliases and true
                    end
                },
                prefixAliases = {
                    type = "toggle",
                    name = L["Prefix Aliases"],
                    order = 3,
                    desc = L["Determines whether or not command aliases are prefixed with _."],
                    set = function(_, value)
                        Addon.db.global.prefixAliases = value and true
                        Addon:SetupCommands()
                    end,
                    get = function(_)
                        return
                            Addon.db.global.prefixAliases and true
                    end
                },
                headerCommands = {
                    type = "header",
                    name = L["Commands"],
                    order = k_commandOrderStart,
                    hidden = function()
                        return not AnyCommandsVisible(s_options.args.commands.args)
                    end
                },
                footerCommands = {
                    type = "description",
                    name = "\n",
                    order = k_commandOrderEnd,
                    hidden = function()
                        return not AnyCommandsVisible(s_options.args.commands.args)
                    end
                },
                headerAliases = {
                    type = "header",
                    name = L["Aliases"],
                    order = k_aliasOrderStart,
                    hidden = function()
                        return not AnyAliasesVisible(s_options.args.commands.args)
                    end
                },
                footerAliases = {
                    type = "description",
                    name = "\n",
                    order = k_aliasOrderEnd,
                    hidden = function()
                        return not AnyAliasesVisible(s_options.args.commands.args)
                    end
                }
            }
        },
    }
}

local function PopulateProfileOptions(order)
    if s_options.args.profiles == nil then
        s_options.args.profiles = AceDBOptions:GetOptionsTable(Addon.db)
    end

    local options = s_options.args.profiles
    options.order = order
    order = order + 1

    return order
end

local function PopulateModulesOptions(order)
    local options = s_options.args.modules
    local args = options.args

    options.order = order
    order = order + 1

    local toggleOrder = 1
    local moduleOrder = 1
    for name, module in Addon:IterateModules() do
        -- add option to toggle the module
        args[name .. "Toggle"] = {
            type = "toggle",
            name = module.name,
            order = toggleOrder,
            desc = module.description or format(L["Enable the %s module."], name),
            get = function(_)
                return Addon:ShouldModuleBeEnabled(name)
            end,
            set = function(_, value)
                local enabled = Addon:SetShouldModuleBeEnabled(name, value)
                Addon:ToggleModule(name, module, enabled)
            end,
        }
        toggleOrder = toggleOrder + 1

        local moduleOptions = {
            type = "group",
            name = module.name,
            desc = module.description,
            disabled = function()
                return not Addon:ShouldModuleBeEnabled(name)
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

        local includeModule = module.commands and true

        -- populate with any module specific options
        local optionOrder = 2
        if module["Options"] then
            moduleOptions.args.headerOptions = {
                type = "header",
                name = L["Options"],
                order = optionOrder,
            }
            optionOrder = optionOrder + 1

            for key, value in pairs(module:Options()) do
                moduleOptions.args[key] = value
                if moduleOptions.args[key].order ~= nil then
                    moduleOptions.args[key].order = moduleOptions.args[key].order + optionOrder
                else
                    moduleOptions.args[key].order = optionOrder
                    optionOrder = optionOrder + 1
                end
            end

            includeModule = true
        end

        -- if we found commands or options then add it to the last
        if includeModule then
            moduleOptions.order = moduleOrder
            moduleOrder = moduleOrder + 1
            args[name] = moduleOptions
        end
    end

    return order
end

local function PopulateCommands(order)
    local options = s_options.args.commands

    options.order = order
    order = order + 1

    local commandArgs = {}
    local commandNames = {}

    local aliasArgs = {}
    local aliasNames = {}

    -- build command and alias args from all modules
    for moduleKey, module in Addon:IterateModules() do
        if module.commands then
            for commandName in pairs(module.commands) do
                table.insert(commandNames, commandName)
                commandArgs[commandName] = {
                    type = "description",
                    name = L[moduleKey .. "." .. commandName],
                    hidden = function()
                        return not Addon:ShouldModuleBeEnabled(moduleKey)
                    end
                }
            end
        end
        if module.aliases then
            for alias, commandName in pairs(module.aliases) do
                table.insert(aliasNames, alias)
                aliasArgs[alias] = {
                    type = "description",
                    name = function()
                        local prefix = Addon.db.global.prefixAliases and Addon.AliasPrefix or ""
                        return format(L["/%s%s -> "], prefix, alias) .. L[moduleKey .. "." .. commandName]
                    end,
                    hidden = function()
                        return not (Addon.db.global.allowAliases and Addon:ShouldModuleBeEnabled(moduleKey))
                    end,
                }
            end
        end
    end

    -- sort and populate commands
    if commandArgs then
        table.sort(commandNames)
        for commandOrder, commandName in ipairs(commandNames) do
            commandArgs[commandName].order = k_commandOrderStart + commandOrder
            options.args[commandName] = commandArgs[commandName]
        end
    end

    -- sort and populate aliases
    if aliasArgs then
        table.sort(aliasNames)
        for aliasOrder, aliasName in ipairs(aliasNames) do
            aliasArgs[aliasName].order = k_aliasOrderStart + aliasOrder
            options.args[aliasName] = aliasArgs[aliasName]
        end
    end

    -- copy command and aliases into the modules options
    for moduleKey, module in Addon:IterateModules() do
        local moduleOptions = s_options.args.modules.args[moduleKey]
        local function Clone(args, hidden)
            local cloneArgs = Addon.Clone(args, 1) -- shallow clone
            cloneArgs.hidden = hidden
            return cloneArgs
        end
        if module.commands then
            local function IsHidden()
                return not AnyCommandsVisible(moduleOptions.args)
            end
            moduleOptions.args.headerCommands = Clone(options.args.headerCommands, IsHidden)
            moduleOptions.args.footerCommands = Clone(options.args.footerCommands, IsHidden)
            for command_name in pairs(module.commands) do
                moduleOptions.args[command_name] = commandArgs[command_name]
            end
        end
        if module.aliases then
            local function IsHidden()
                return not AnyAliasesVisible(moduleOptions.args)
            end
            moduleOptions.args.headerAliases = Clone(options.args.headerAliases, IsHidden)
            moduleOptions.args.footerAliases = Clone(options.args.footerAliases, IsHidden)
            for aliasName in pairs(module.aliases) do
                moduleOptions.args[aliasName] = aliasArgs[aliasName]
            end
        end
    end

    return order
end

function Addon:RegisterDB()
    Addon.Trace("Addon:RegisterDB")

    self.db = AceDB:New("ChatbotDB", k_defaults, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

    AceConfig:RegisterOptionsTable(AddonName, s_options)
    self.dbFrame = AceConfigDialog:AddToBlizOptions(AddonName, self.name);

    self:RegisterChatCommand("chatbot", "CmdShowOptions")
end

function Addon:SetupOptions()
    Addon.Trace("Addon:SetupOptions")

    local order = 1
    order = PopulateProfileOptions(order)
    order = PopulateModulesOptions(order)
    order = PopulateCommands(order)
end

function Addon:CmdShowOptions(input)
    Addon.TraceF("Addon:ShowOptions(%s)", input)

    if not AceConfigDialog.OpenFrames[AddonName] then
        AceConfigDialog:Open(AddonName)
    else
        AceConfigDialog:Close(AddonName)
    end
end

function Addon:OnProfileChanged()
    Addon.Trace("Addon:OnProfileChanged")

    self:DisableAllModules(true)
    self:EnableAllModules()

    collectgarbage('collect');
end