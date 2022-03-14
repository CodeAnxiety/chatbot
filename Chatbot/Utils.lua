local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local k_logLevels = {
    Trace = 1,
    Debug = 2,
    Info = 3,
    Warning = 4,
    Error = 5,
    Assert = 6,
    LAST = 7,
}
local k_LogNames = {
    "trace",
    "debug",
    "info",
    "warning",
    "error",
    "assert",
}
local s_logPreambles = {
    "|cff606060Trace:|r ",
    "|cff40c0c0Debug:|r ",
    "",
    "|cffc0c040Warning:|r ",
    "|cffc04040Error:|r ",
    "|cffFF0000Assert Failure:|r ",
}

-- If you want to enable tracing or debugging at addon load, then you must set this here
local s_logLevel = k_logLevels.Info

local function Log(level, message)
    if level >= s_logLevel then
        message = s_logPreambles[level] .. message;
        if level >= k_logLevels.Error then
            error(message)
        else
            print(message)
        end
    end
end

local function Logf(level, message, ...)
    if level >= s_logLevel then
        Log(level, format(message, ...));
    end
end

function Addon.Trace(message)
    Log(k_logLevels.Trace, message)
end
function Addon.Tracef(message, ...)
    Logf(k_logLevels.Trace, message, ...)
end
function Addon.Debug(message)
    Log(k_logLevels.Debug, message)
end
function Addon.Debugf(message, ...)
    Logf(k_logLevels.Debug, message, ...)
end
function Addon.Log(message)
    Log(k_logLevels.Info, message)
end
function Addon.Logf(message, ...)
    Logf(k_logLevels.Info, message, ...)
end
function Addon.Warning(message)
    Log(k_logLevels.Warning, message)
end
function Addon.Warningf(message, ...)
    Logf(k_logLevels.Warning, message, ...)
end
function Addon.Error(message)
    Log(k_logLevels.Error, message)
end
function Addon.Errorf(message, ...)
    Logf(k_logLevels.Error, message, ...)
end
function Addon.Assert(condition, message)
    if not condition then
        Log(k_logLevels.Assert, message)
    end
end
function Addon.Assertf(condition, message, ...)
    if not condition then
        Logf(k_logLevels.Assert, message, ...)
    end
end

function Addon.GetLogLevel()
    return s_logLevel, k_LogNames[s_logLevel]
end

function Addon.SetLogLevel(level)
    local level_type = type(level)
    Addon.Assert(level_type == "number" or level_type == "string", "level must be a number or string")

    if level_type == "string" then
        local found = false
        level = level:lower()
        for index, name in ipairs(k_LogNames) do
            if name == level then
                level = index
                found = true
                break
            end
        end
        Addon.Assertf(found, "invalid log level: %s", level)
    end

    Addon.Assertf(level >= 1 and level < k_logLevels.LAST, "invalid log level: %d", level)

    s_logLevel = level
    Log(level, "Log level updated.")
end

function Addon.Escape(text)
    if type(text) == "string" then
        text = text:gsub("\\", "\\\\")
        text = text:gsub("\"", "\\\"")
        text = text:gsub("\t", "\\t")
        text = text:gsub("\r", "\\r")
        text = text:gsub("\n", "\\n")
        text = "\"" .. text .. "\""
    end
    return text
end

function Addon.IsIdentifier(name)
    return type(name) == "string" and name:gmatch("^[A-Za-z_][A-Za-z0-9_]*$")
end

function Addon.Dump(name, value, maxDepth, depth)
    name = name or "()"
    maxDepth = maxDepth or 4
    depth = depth or 0

    if depth > maxDepth then return end

    local text = string.rep("  ", depth)
    if type(name) == "number" then
        text = text .. "[" .. name .. "]"
    elseif Addon.IsIdentifier(name) then
        text = text .. name
    else
        text = text .. "[" .. Addon.Escape(name) .. "]"
    end

    local valueType = type(value)
    if valueType == "table" then
        Addon.Log(text .. " = {")
        for k, v in pairs(value) do
            Addon.Dump(k, v, maxDepth, depth + 1)
        end
        text = string.rep("  ", depth) .. "}"
    elseif valueType == "boolean" then
        text = text .. " = " .. tostring(value)
    elseif valueType == "string" then
        text = text .. " = " .. Addon.Escape(value)
    elseif valueType == "number" then
        text = text .. " = " .. value
    elseif valueType == "nil" then
        text = text .. " = " .. "nil"
    else
        text = text .. " = " .. "nil --[[" .. valueType .. "]]"
    end

    if depth > 0 then
        text = text .. ","
    end

    Addon.Log(text)
end

---
--- Creates a clone of the provided value up to a maximum depth (default: 1).
---
--- @param value table
--- @return table
---
function Addon.Clone(value, maxDepth, depth)
    if type(value) ~= "table" then
        return value
    end

    maxDepth = depth or 1
    depth = depth or 1

    local result = {}
    for key, child_value in pairs(value) do
        if depth < maxDepth and type(child_value) == "table" then
            child_value = Addon.Clone(child_value, maxDepth, depth + 1)
        end
        result[key] = child_value
    end

    return result
end

---
--- Chooses a random value from a table.
---
--- @param values table[any]
--- @return any
---
function Addon.Choose(values)
    return values[random(#values)] or nil
end

function Addon.Trim(input)
    input = tostring(input or "")

    input = strtrim(input, " \t\n")
    return input
end

function Addon.Split(input, separator)
    separator = tostring(separator or "\n")

    input = tostring(input or "") -- ensure valid string
    input = input:gsub(separator.."+", separator) -- remove empty lines in middle
    input = Addon.Trim(input)

    local results = {}
    for result in string.gmatch(input, "([^"..separator.."]+)") do
        result = Addon.Trim(result)
        if result ~= "" then
            table.insert(results, result)
        end
    end

    return results
end

function Addon.UpsertMacro(name, icon, body, perCharacter)
    local index = GetMacroIndexByName(name)

    local id
    if index ~= nil and index ~= 0 then
        id = EditMacro(index, name, icon, body)
    else
        id = CreateMacro(name, icon, body, perCharacter)
    end

    if id == nil then
        Addon:Warningf(L["Could not update macro %s."], name)
    end
end

local s_delayFrame = nil
local s_delayQueue = {}

---
--- Executes a callback after the specified delay.
---
--- @param delay number The numbers of seconds to wait.
--- @param callback function The function to call when the delay has elapsed.
--- @param ... any The argument(s) for the callback.
---
--- @note Adapted from: https://wowwiki-archive.fandom.com/wiki/USERAPI_wait
---
function Addon.Delay(delay, callback, ...)
    Addon.Assert(type(delay) == "number", "delay must be a number")
    Addon.Assert(type(callback) == "function", "callback must be a function")

    if not s_delayFrame then
        s_delayFrame = CreateFrame("Frame", "Chatbot.DelayFrame", UIParent)
        s_delayFrame:SetScript("OnUpdate", function(_, elapsed_time)
            local index = 1
            local count = #s_delayQueue
            while index <= count do
                local entry = table.remove(s_delayQueue, index)
                entry.lifespan = entry.lifespan - elapsed_time
                if entry.lifespan > 0 then
                    table.insert(s_delayQueue, index, entry)
                    index = index + 1
                else
                    count = count - 1
                    entry.callback(unpack(entry.arguments))
                end
            end
        end)
    end

    table.insert(s_delayQueue, {
        lifespan = delay,
        callback = callback,
        arguments = {...}
    })
end