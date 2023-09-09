local pathData = "background_npcs/autotoggler/"

function isNumberInRange(number, min, max)
    return number >= min and number <= max
end

local function getDefaultSettings()
    local fullPath = pathData .. "settings/default.json"
    if not file.Exists(fullPath, "DATA") then
        file.CreateDir(pathData .. "settings/")
        file.Write(fullPath, util.TableToJSON({enable = 1, max_npc = 35}))
    end
    return util.JSONToTable(file.Read(fullPath, "DATA"))
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
    return util.JSONToTable(fileContent)
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

local function bgn_autotoggler_save()
    local currentMap = game.GetMap()
    local enable = GetConVar("bgn_enable"):GetInt()
    local max_npc = GetConVar("bgn_max_npc"):GetInt()

    local newMapSettings = {
        enable = enable,
        max_npc = max_npc
    }

    writeMapSettings(currentMap, newMapSettings)
end

local function bgn_autotoggler_default()
    local currentMap = game.GetMap()
    writeMapSettings(currentMap)
    loadMapSettings()
    PrintMessage(HUD_PRINTCONSOLE, "[Background NPCs - Auto Toggler] Default settings loaded")
end

local function bgn_autotoggler_default_change(enable, max_npc)
    if (not enable or not isNumberInRange(enable, 0, 1)) or (not max_npc or not isNumberInRange(max_npc, 0, 200)) then
        PrintMessage(HUD_PRINTCONSOLE, "bgn_autotoggler_default_change [enable] [max_npc] - enable = 0 or 1, max_npc = between 0 and 200")
        return
    end

    local fullPath = pathData .. "settings/default.json"
    file.Write(fullPath, util.TableToJSON({enable = enable, max_npc = max_npc}))
    PrintMessage(HUD_PRINTCONSOLE, "[Background NPCs - Auto Toggler] New default settings: " .. enable .. " " .. max_npc)
end

concommand.Add("bgn_autotoggler_save", function(player)
    if not player:IsSuperAdmin() then return end
    bgn_autotoggler_save()
end)

concommand.Add("bgn_autotoggler_default", function(player)
    if not player:IsSuperAdmin() then return end
    bgn_autotoggler_default()
end)
concommand.Add("bgn_autotoggler_default_change", function(player, _, args)
    if not player:IsSuperAdmin() then return end
    bgn_autotoggler_default_change(tonumber(args[1]), tonumber(args[2]))
end)

cvars.AddChangeCallback("bgn_enable", bgn_autotoggler_save)
cvars.AddChangeCallback("bgn_max_npc", bgn_autotoggler_save)

hook.Add("Initialize", "bgn_autotoggler_startup", loadMapSettings)
