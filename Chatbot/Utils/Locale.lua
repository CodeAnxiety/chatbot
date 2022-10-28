function StyleText(text)

    -- shortcuts
    text = text:gsub("<b>", "|cff00c0f0") -- Bold
    text = text:gsub("<m>", "|cb0606060") -- Muted
    text = text:gsub("<c>", "|cff00f0c0") -- Commands
    text = text:gsub("<p>", "|cff00c080") -- Parameters
    text = text:gsub("<o>", "|cff808080") -- Optional parameters
    text = text:gsub("<h>", "|cffb060b0") -- Help text
    text = text:gsub("<w>", "|cfff0c000") -- Warnings
    text = text:gsub("</>", "|r") -- Reset

    -- raw colors
    text = text:gsub("<#(%x%x%x%x%x%x%x%x)>", "|c%1")
    text = text:gsub("<#(%x%x%x%x%x%x)>", "|cff%1")
    text = text:gsub("<#(%x)(%x)(%x)(%x)>", "|c%1%1%2%2%3%3%4%4")
    text = text:gsub("<#(%x)(%x)(%x)>", "|cff%1%1%2%2%3%3")

    return text
end

