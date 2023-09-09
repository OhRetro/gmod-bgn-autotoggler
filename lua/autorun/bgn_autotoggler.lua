local pathData = "background_npcs/autotoggler/"

function isNumberInRange(number, min, max)
    return number >= min and number <= max
end

local function getDefaultSettings()
    return {
        enable = 1,
        max_npc = 35
    }
end

local function writeMapSettings(mapName, settings)
    settings = settings or getDefaultSettings()
    local settingsContent = util.TableToJSON(settings)
    file.Write(pathData .. mapName .. ".json", settingsContent)
end

local function readMapSettings(mapName)
    local filePath = pathData .. mapName .. ".json"
    if not file.Exists(filePath, "DATA") then
        PrintMessage(HUD_PRINTTALK, "[Background NPCs - Auto Toggler] " .. mapName .. ".json not found, generating default settings for " .. mapName)
        writeMapSettings(mapName)
    else
        PrintMessage(HUD_PRINTTALK, "[Background NPCs - Auto Toggler] " .. mapName .. ".json found, reading settings for " .. mapName)
    end
    local fileContent = file.Read(filePath, "DATA")
    return util.JSONToTable(fileContent) or getDefaultSettings()
end

local function setMapSettings(mapSettings)
    for key, value in pairs(mapSettings) do
        if not value then
            value = getDefaultSettings()[key]
        end
        game.ConsoleCommand("bgn_" .. key .. " " .. value .. "\n")
    end
end

local function loadMapSettings()
    local currentMap = game.GetMap()

    if not file.Exists(pathData, "DATA") then
        file.CreateDir(pathData)
    end
    
    local currentMapSettings = readMapSettings(currentMap)
    
    PrintMessage(HUD_PRINTTALK, "[Background NPCs - Auto Toggler] " .. currentMap .. " | " .. currentMapSettings.enable .. " | " .. currentMapSettings.max_npc)

    setMapSettings(currentMapSettings)
end

local function bgn_autotoggler_default_change(player, _, args)
    local enable, max_npc = tonumber(args[1]), tonumber(args[2])
    
    if not player:IsSuperAdmin() or not isNumberInRange(enable, 0, 1) or not isNumberInRange(max_npc, 0, 200) then
        PrintMessage(HUD_PRINTCONSOLE, "bgn_autotoggler_default_change [enable] [max_npc] - enable = 0 or 1, max_npc = between 0 and 200")
        return
    end

    -- Apply your default settings change logic here
    print("Default settings changed:", enable, max_npc)
end

concommand.Add("bgn_autotoggler_write", bgn_autotoggler_write)
concommand.Add("bgn_autotoggler_reload", bgn_autotoggler_reload)
concommand.Add("bgn_autotoggler_default_change", bgn_autotoggler_default_change, nil, "changes the default settings to generate for every map that haven't being played yet")

cvars.AddChangeCallback("bgn_enable", bgn_autotoggler_write)
cvars.AddChangeCallback("bgn_max_npc", bgn_autotoggler_write)

hook.Add("Initialize", "bgn_autotoggler_startup", loadMapSettings)