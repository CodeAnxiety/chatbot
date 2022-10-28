local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local kLogLevels = {
    Trace = 1,
    Debug = 2,
    Info = 3,
    Warning = 4,
    Error = 5,
    Assert = 6,
    LAST = 7,
}
local kLogNames = {
    "trace",
    "debug",
    "info",
    "warning",
    "error",
    "assert",
}
local kLogDLPreamble = {
    "OK~Trace: ",
    "OK~Debug: ",
    "",
    "WARN~",
    "ERR~",
    "ERR~Assert Failure: ",
}

local kLogPreambles = {
    L["Log Trace: "],
    L["Log Debug: "],
    L["Log Info: "],
    L["Log Warning: "],
    L["Log Error: "],
    L["Log Assert: "],
}

-- If you want to enable tracing or debugging at addon load, then you must set this here
local sLogLevel = kLogLevels.Debug

local function Localize(message)
    repeat
        local changed = false
        message = string.gsub(message, "%$([A-Za-z_][A-Za-z0-9_]+(:[A-Za-z_][A-Za-z0-9_]+)*)", function(match)
            local replacement = L[match]
            if replacement ~= nil and replacement ~= match then
                changed = changed or (replacement ~= match)
                return replacement
            else
                return string.gsub(match, "^.+:(.+?)$", "%1")
            end
        end)
    until not changed
    return message
end

---
--- Logs a message, formatted using additional arguments, if the level exceeds the current level.
---
--- @param level integer The log level.
--- @param message string The message format.
--- @param ... any The values to be formatted.
---
local function Log(level, message, ...)
    if level < sLogLevel then
        return
    end

    local localized = Localize(format(L[message] or message, ...))

    if level == kLogLevels.Info then
        Addon:Print(localized)
    elseif _G.DLAPI then
        _G.DLAPI.DebugLog(AddonName, kLogDLPreamble[level] .. localized)
    elseif level >= kLogLevels.Error then
        error(kLogPreambles[level] .. localized)
    else
        print(kLogPreambles[level] .. localized)
    end
end

function Addon.Trace(message, ...)
    Log(kLogLevels.Trace, message, ...)
end

function Addon.Debug(message, ...)
    Log(kLogLevels.Debug, message, ...)
end

function Addon.Info(message, ...)
    Log(kLogLevels.Info, message, ...)
end

function Addon.Warning(message, ...)
    Log(kLogLevels.Warning, message, ...)
end

function Addon.Error(message, ...)
    Log(kLogLevels.Error, message, ...)
end

function Addon.Assert(condition, message, ...)
    if not condition then
        Log(kLogLevels.Assert, message, ...)
    end
end

function Addon.GetLogLevel()
    return sLogLevel, kLogNames[sLogLevel]
end

---
--- Attempts to parse the given input as a log level.
---
--- @param level any Input to parse
--- @return integer level Log level
---
local function ParseLogLevel(level)
    if type(level) == "string" then
        local lowered = level:lower()
        for index, name in ipairs(kLogNames) do
            if name == lowered then
                return index
            end
        end
    elseif type(level) == "number" then
        for index, _ in ipairs(kLogNames) do
            if index == level then
                return index
            end
        end
    end
    return nil
end

function Addon.SetLogLevel(value)
    local level = ParseLogLevel(value)
    if level == nil then
        Addon.Error("Invalid log level: %s", level)
    end

    sLogLevel = level or kLogLevels.Info
    Addon.Info("Log level updated: %s", "$LogLevel:" .. kLogNames[level])
end

function Addon.Quoted(text)
    text = tostring(text or "")
    text = text:gsub("\\", "\\\\")
    text = text:gsub("\"", "\\\"")
    text = text:gsub("\t", "\\t")
    text = text:gsub("\r", "\\r")
    text = text:gsub("\n", "\\n")
    text = "\"" .. text .. "\""
end

function Addon.MakePattern(pattern, caseSensitive)
    return string.gsub(pattern, ".", function(char)
        if char == "*" then
            return '.+'
        elseif char == "?" then
            return '.'
        elseif char == "%" then
            return "%%"
        elseif not caseSensitive and string.match(char, "%a") then
            return "[" .. char:upper() .. char:lower() .. "]"
        else
            return char
        end
    end)
end

function Addon.IsIdentifier(name)
    return string.match(name, "^[A-Za-z_][A-Za-z0-9_]*$")
end

function Addon.AppendTable(target, ...)
    for i = 1, select("#", ...) do
        table.insert(target, select(i, ...))
    end
end

function Addon.IsArray(target)
    return type(target) == "table" and #target > 0
end

function Addon.ToString(...)
    local serializer = Addon.Utils.Serializer:new("")
    serializer:Write(...)
    return serializer:ToString()
end

---
--- Serializes the value into a Lua evaluable string.
---
--- @param ... any The value(s) to serialize.
---
function Addon.Serialize(...)
    local serializer = Addon.Utils.Serializer:new()
    serializer:Write(...)
    return serializer:ToString()
end

---
--- Dumps the specified value to the log.
---
--- @param ... any
---
function Addon.Dump(...)
    Addon.Debug(Addon.Serialize(...))
end

---
--- Creates a clone of the provided value up to a maximum depth.
---
--- @param value table The table to clone.
--- @param maxDepth integer The maximum depth. (default: 1)
--- @param depth integer The current depth. (default: 1)
--- @return table table Cloned table.
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
--- @param fallback any
--- @return any|nil
---
function Addon.Choose(values, fallback)
    if type(values) == "table" then
        local index = #values
        if index > 0 then
            return values[random(index)] or fallback and Addon.Choose(fallback) or nil
        else
            return fallback and Addon.Choose(fallback) or nil
        end
    else
        return values or fallback and Addon.Choose(fallback) or nil
    end
end

---
--- Removing extraneous characters from the beginning and end of a string.
---
--- @param input string String to trim.
--- @param chars string|nil Characters to trim. (default: " \t\n")
--- @return string string Trimmed version of the string.
---
function Addon.Trim(input, chars)
    input = tostring(input or "")
    chars = tostring(chars or " \t\n")

    return strtrim(input, chars)
end

---
--- Splits the inputted string into an array.
---
--- @param input string String to split.
--- @param chars string|nil The characters to split at. (default: ";\n")
--- @return table array The values that were split.
---
function Addon.Split(input, chars)
    input = tostring(input or "")
    chars = tostring(chars or ";\n")

    local results = {}
    for result in string.gmatch(input, "([^" .. chars .. "]+)") do
        result = Addon.Trim(result)
        if result ~= "" then
            table.insert(results, result)
        end
    end

    return results
end

function Addon.Join(input, separator)
    separator = tostring(separator or " ")
    if type(input) == "table" then
        return table.concat(input, separator)
    else
        return tostring(input or "")
    end
end

---
--- Splits the inputted string into two values
---
--- @param input string String to split.
--- @param chars string|nil The characters to split at. (default: ";\n")
--- @return string before The text before the separator.
--- @return string|nil after The text after the separator or nil if separator not found.
---
function Addon.SplitOnce(input, chars)
    input = tostring(input or "")
    chars = tostring(chars or ";\n")

    local start, stop = string.find(input, "[" .. chars .. "]+", 1)
    if start then
        local before = string.sub(input, 1, start - 1)
        local after = string.sub(input, stop + 1)
        return before, after
    end

    return input
end

function Addon.UpsertMacro(name, icon, body, perCharacter)
    name = L[name] or name
    local index = GetMacroIndexByName(name)

    local id
    if index ~= nil and index ~= 0 then
        id = EditMacro(index, name, icon, body)
    else
        id = CreateMacro(name, icon, body, perCharacter)
    end

    if id == nil then
        Addon.Warning("Could not update macro %s.", name)
    end
end