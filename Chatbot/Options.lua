local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

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

        local include_module = false
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

        local option_order = 2

        -- create section for the module's commands
        if module["Commands"] then
            local commands = {}
            for command in pairs(module:Commands()) do
                table.insert(commands, command)
            end
            table.sort(commands)

            local help = ""
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

            local help = ""
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
    local order = 1
    OPTIONS.args.profiles, order = BuildProfileOptions(order)
    OPTIONS.args.modules, order = BuildModulesOptions(order)
end

function Addon:SetupOptions(register)
    if register then
        self.db = AceDB:New("ChatbotDB", DEFAULTS, true)
        self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

        AceConfig:RegisterOptionsTable(AddonName, OPTIONS, {AddonName})
        self.dbFrame = AceConfigDialog:AddToBlizOptions(AddonName, self.name);
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