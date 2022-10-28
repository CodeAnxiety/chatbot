-- spell-checker:ignore pemote pchat Leeroy bzzzt

local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local Module = Addon:NewModule("Personality", "AceConsole-3.0")
Module.name = L["Personality"]
Module.description = L[
    "The Personality module provides predefined text to other modules that changes based on your currently selected personality."
    ]
Module.commands = {
    ["personality"] = "CmdPersonality",
    ["personality_emote"] = "CmdSendEmote",
    ["personality_chat"] = "CmdSendChat",
}
Module.aliases = {
    ["pemote"] = "personality_emote",
    ["pchat"] = "personality_chat",
}

local k_supported = {
    hello = {
        name = L["Hello"],
        description = L["Send greetings."],
    },
    bye = {
        name = L["Bye"],
        description = L["Send farewell."],
    },
    thank = {
        name = L["Thank"],
        description = L["Say thanks."],
    },
    thank_fake = {
        name = L["Thank"],
        description = L['Say "thanks".'],
    },
    attack = {
        name = L["Attack"],
        description = L["Send others into battle."],
    },
    charge = {
        name = L["Charge"],
        description = L["Lead others into battle."],
    },
    inspire = {
        name = L["Inspire"],
        description = L["Inspire the troops before battle."],
    },
    rally = {
        name = L["Rally"],
        description = L["Rally the troops during battle."],
    },
    incoming = {
        name = L["Incoming"],
        description = L["Warn others of incoming enemies."],
    },
    help = {
        name = L["Help"],
        description = L["Let others know you need help."],
    },
    angry = {
        name = L["Angry"],
        description = L["Vent your frustration."],
    },
    apologize = {
        name = L["Apologize"],
        description = L["Apologize for your mistake."],
    },
    apologize_fake = {
        name = L["Apologize (Fake)"],
        description = L['"Apologize" for your "mistake".'],
    },
    cheer = {
        name = L["Cheer"],
        description = L["Cheer what just happened."],
    },
    confused = {
        name = L["Confused"],
        description = L["Express your confusion."],
    },
    funny = {
        name = L["Funny"],
        description = L["Say something funny."],
    },
    funny_fake = {
        name = L["Funny (Fake)"],
        description = L['Say something "funny".'],
    },
    insult = {
        name = L["Insult"],
        description = L["Throw shade."],
    },
    mourn = {
        name = L["Mourn"],
        description = L["Mourn the loss of the departed."],
    },
    threaten = {
        name = L["Threaten"],
        description = L["Threaten your enemy."],
    },
    threaten_fake = {
        name = L["Threaten (Fake)"],
        description = L['"Threaten" your enemy.'],
    },
    flavor = {
        name = L["Flavor"],
        description = L["Personality specific flavor."],
    }
}

local k_defaults = {
    global = {
    },
    profile = {
        hello = {
            ["Generic"] = {
                emotes = {
                    "wave",
                    "hello",
                    "greet",
                },
                messages = {
                    L["Hello!"],
                    L["Hey!"],
                },
            },
        },
        bye = {
            ["Generic"] = {
                emotes = {
                    "bye",
                    "farewell",
                    "wave",
                },
                messages = {
                    L["Goodbye!"],
                    L["Bye!"],
                },
            },
        },
        thank = {
            ["Generic"] = {
                emotes = {
                    "thank",
                },
                messages = {
                    L["Thank you!"],
                    L["Thanks!"],
                }
            },
        },
        attack = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["Attack!"],
                    L["Go get 'em!"],
                },
            },
        },
        charge = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["Charge!"],
                    L["Let's do this!"],
                    L["Leeroy Jenkins!"],
                },
            },
        },
        inspire = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["We've got this!"],
                },
            },
        },
        rally = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["Shake it off!"]
                },
            },
        },
        incoming = {
            ["Generic"] = {
                emotes = {
                    "incoming",
                    "brandish",
                },
                messages = {
                    L["Incoming!"],
                },
            },
        },
        help = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["I need help!"],
                },
            },
        },
        angry = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["That makes me angry!"],
                },
            },
        },
        apologize = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["Sorry!"]
                },
            },
        },
        apologize_insincere = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["I'm soOoOo sorry! /s"]
                },
            },
        },
        cheer = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["Woo!"],
                },
            },
        },
        confused = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["What was that?"]
                },
            },
        },
        funny = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["Chatbot error, 'funny' file not found."],
                },
            },
        },
        insult = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["I think my cat is smarter than you."]
                },
            },
        },
        mourn = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["I can't believe that happened..."],
                },
            },
        },
        threaten = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["Don't make me come over there..."]
                },
            },
        },
        threaten_fake = {
            ["Generic"] = {
                emotes = {
                },
                messages = {
                    L["Don't make me come over there... (please)"]
                },
            },
        },
        flavor = {
            ["Generic"] = {
                emotes = {

                },
                messages = {
                    L["Leeroy Jenkins is my hero!"]
                },
            }
        }
    },
    char = {},
}

local s_options = {
    personality = {
        type = "input",
        name = L["Selected Personality"],
        order = 1,
        desc = L["The personality to use."],
        set = function(_, value)
            Module.db.char.personality = value
        end,
        get = function(_)
            return Module.db.char.personality or "Generic"
        end,
    }
}

function Module:Options()
    return s_options
end

function Module:OnInitialize()
    Addon.Trace("Module[%s]:OnInitialize", self.name)

    self.db = Addon.db:RegisterNamespace("Personality", k_defaults)
end

---
--- Usage: /personality [personality]
---
function Module:CmdPersonality(input)
    Addon.Trace("Module[%s]:CmdPersonality(%s)", self.name, input)

    if input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon.Info("Usage: %s", "$Usage:personality")
        return
    end

    local command, pos = Addon:GetArgs(input, 1)
    input = string.sub(input, pos)
    Addon.Debug("Command: %s", command)

    if command == 'actions' then
        local search, pos = Addon:GetArgs(input, 1)
        input = string.sub(input, pos)

        local pattern = Addon.MakePattern(search)
        Addon.Debug("Search: %s, Pattern: %s", search, pattern)

        local function MatchAction(key, action)
            return search == "" or
                key == search or
                string.match(action.name, pattern) or
                string.match(action.description, pattern)
        end

        Addon.Info("Supported Actions:")
        local found = 0
        for key, action in pairs(k_supported) do
            if MatchAction(key, action) or
                string.match(action.description, pattern) then
                Addon.Info("  [%s] %s : %s", key, action.name, action.description)
                found = found + 1
            end
        end
        if found == 0 then
            Addon.Info("  Nothing found for %q.", search)
        end
    end

end

function Module:CmdSendEmote(input)
    Addon.Trace("Module[%s]:CmdSendEmote(%s)", self.name, input)

    if input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon.Info("Usage: %s", "$Usage:personality_emote")
        return
    end

    local action, pos = Addon:GetArgs(input, 1)
    local fallback = Addon.Split(string.sub(input, pos), " ,;")

    local emote = self:GetPersonalityEmote(action, fallback)
    Addon.Debug("Emote: %q", emote or '(nil)')

    if emote == nil then
        Addon.Info("Could not find emote for action: %q", action)
        Addon.Info("Pro tip: Everything after the first word will be used at random as a fallback.")
        return
    end

    DoEmote(emote, "none")
end

function Module:CmdSendChat(input)
    Addon.Trace("Module[%s]:CmdSendChat(%s)", self.name, input)

    if input == "" or input == "-?" or input == "-h" or input == "-help" then
        Addon.Info("Usage: %s", "$Usage:personality_chat")
        return
    end

    local action, pos = Addon:GetArgs(input, 1)
    local fallback = Addon.Split(string.sub(input, pos))

    local message = self:GetPersonalityMessage(action, fallback)
    Addon.Debug("Message: %q", message or '(nil)')
    if message == nil then
        Addon.Info("Could not find message for action: %q", action)
        Addon.Info("Pro tip: Everything after the first word will be used as a fallback.")
        return
    end

    SendChatMessage(message, "SAY", DEFAULT_CHAT_FRAME.editBox.languageID)
end

local function GetPersonalityEntry(action, field, fallback)
    local actionTable = Module.db.profile[action]
    if actionTable ~= nil then
        local personality = Module.db.char.personality or "Generic"
        local personalityTable = actionTable[personality]
        if personalityTable ~= nil then
            local values = personality[field]
            if values ~= nil then
                return Addon.Choose(values, fallback)
            end
        end
    end
    return Addon.Choose(fallback)
end

function Module:GetPersonalityEmote(action, fallback)
    Addon.Trace("Module[%s]:GetPersonalityEmote(%q, %q)", self.name, action or '', Addon.Join(fallback))

    return GetPersonalityEntry(action, "emotes", fallback)
end

function Module:GetPersonalityMessage(action, fallback)
    Addon.Trace("Module[%s]:GetPersonalityMessage(%q, %q)", self.name, action or '', Addon.Join(fallback))

    return GetPersonalityEntry(action, "messages", fallback)
end