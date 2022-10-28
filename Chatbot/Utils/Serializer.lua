local _, Addon = ...

local Serializer = {}
Addon.Utils = Addon.Utils or {}
Addon.Utils.Serializer = Serializer

local function IsShort(value, nested)
    local valueType = type(value)
    if valueType == "nil" or valueType == "boolean" or valueType == "number" then
        return true
    elseif valueType == "string" then
        return string.len(value) < 10
    elseif valueType == "table" then
        local count = 0
        for k, v in pairs(value) do
            count = count + 1
            if count > 5 or nested then
                return false
            end
            if not IsShort(k, true) or not IsShort(v, true) then
                return false
            end
        end
        return true
    end
    return false
end

local kValueTypes = {
    Invalid = 0,
    Nil = 1,
    Bool = 2,
    Number = 3,
    String = 5,
    Array = 6,
    Map = 7,
}

local function GetValueType(value)
    local valueType = type(value)
    if valueType == "nil" then
        return kValueTypes.Nil
    elseif valueType == "number" then
        return kValueTypes.Number
    elseif valueType == "string" then
        return kValueTypes.String
    elseif valueType == "table" then
        if #value == 0 then
            return kValueTypes.Map
        else
            return kValueTypes.Array
        end
    elseif valueType == "boolean" then
        return kValueTypes.Bool
    end
    return kValueTypes.Invalid
end

local kKeyTypes = {
    Invalid = 0,
    None = 1,
    Number = 2,
    Identifier = 3,
    String = 4,
}

local function GetKeyType(key)
    local keyType = type(key)
    if keyType == "nil" then
        return kKeyTypes.None
    elseif keyType == "number" then
        return kKeyTypes.Number
    elseif keyType == "string" then
        -- Ignore private members.
        if not string.starts(key, "_") then
            if string.match(key, "^[A-Za-z_][A-Za-z0-9_]*$") then
                return kKeyTypes.Identifier
            else
                return kKeyTypes.String
            end
        end
    end
    return kKeyTypes.Invalid
end

local function Quoted(value)
    local text = tostring(value or "")
    text = string.gsub(text, "\\", "\\\\")
    text = string.gsub(text, '"', '\\"')
    text = string.gsub(text, "\t", "\\t")
    text = string.gsub(text, "\n", "\\n")
    text = string.gsub(text, "\r", "\\r")
    return '"' .. text .. '"'
end

function Serializer:new(indent, maxDepth)
    local out = {}
    setmetatable(out, self)
    self.__index = self
    self._indent = type(indent) == "string" and indent or "  "
    self._maxDepth = type(maxDepth) == "number" and maxDepth or 6
    self._depth = 0
    self._parts = {}
    self._objects = 0
    return out
end

function Serializer:Write(...)
    local args = { ... }
    for i = 1, #args do
        if self:_Visit(args[i], 1, nil, self._objects + 1, true) then
            self._objects = self._objects + 1
        end
    end
end

function Serializer:ToString()
    local text = table.concat(self._parts)
    if self._objects ~= 1 then
        return "{" .. text .. "}"
    else
        return text
    end
end

function Serializer:_Write(...)
    local args = { ... }
    for i = 1, #args do
        table.insert(self._parts, args[i])
    end
end

function Serializer:_ShouldIndent()
    return self._indent ~= nil and self._indent ~= ""
end

function Serializer:_WriteIndent(depth)
    if self:_ShouldIndent() then
        self:_Write("\n")
        if depth > 1 then
            self:_Write(string.rep(self._indent, depth))
        end
    end
end

function Serializer:_Visit(value, depth, key, index, short)
    if depth > self._maxDepth then
        return false
    end

    local keyType = GetKeyType(key)
    if keyType == kKeyTypes.Invalid then
        return false
    end

    local valueType = GetValueType(value)
    if valueType == kValueTypes.Invalid then
        return false
    end

    if index ~= nil and index > 1 then
        self:_Write(short and ", " or self:_ShouldIndent() and "," or ", ")
    end

    if short == nil or short == false then
        self:_WriteIndent(depth)
    end

    if depth > 0 then
        if keyType == kKeyTypes.Identifier then
            self:_Write(key, " = ")
        elseif keyType == kKeyTypes.Number then
            self:_Write(format("[%i] = ", key))
        elseif keyType == kKeyTypes.String then
            self:_Write(format("[%q] = ", key))
        end
    end

    if valueType == kValueTypes.Nil then
        self:_Write("nil")
    elseif valueType == kValueTypes.Bool then
        self:_Write(value and "true" or "false")
    elseif valueType == kValueTypes.Number then
        self:_Write(value)
    elseif valueType == kValueTypes.String then
        self:_Write(Quoted(value))
    elseif valueType == kValueTypes.Array or valueType == kValueTypes.Map then
        self:_Write("{")
        local offset = #self._parts
        if depth + 1 <= self._maxDepth then
            short = IsShort(value)
            index = 1
            for k, v in pairs(value) do
                k = valueType == kValueTypes.Map and k or nil
                if self:_Visit(v, depth + 1, k, index, short) then
                    index = index + 1
                end
            end
        end
        if index > 1 and not short and #self._parts > offset then
            self:_WriteIndent(depth)
        end
        self:_Write("}")
    end

    return true
end