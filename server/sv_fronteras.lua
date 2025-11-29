-- ╔══════════════════════════════════════════╗
-- ║  Desarrollado por: Fulgencio Zorongo     ║
-- ║  Compañía: La Colmena Group              ║
-- ╚══════════════════════════════════════════╝

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- Log cuando un jugador cruza una frontera
RegisterNetEvent('lc-fronteras:server:logBorderCrossing')
AddEventHandler('lc-fronteras:server:logBorderCrossing', function(borderName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if Player then
        local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        local citizenid = Player.PlayerData.citizenid

        print(string.format('[LC-FRONTERAS] Jugador %s (%s) cruzó la frontera: %s', playerName, citizenid, borderName))

        -- Aquí puedes añadir un log a base de datos si lo deseas
        -- TriggerEvent('qb-log:server:CreateLog', 'fronteras', 'Border Crossing', 'red',
        --     string.format('%s cruzó la frontera: %s', playerName, borderName))
    end
end)

-- Admin command para teletransportar a un jugador fuera de la zona de ejecución
RSGCore.Commands.Add('rescueborder', 'Rescatar jugador de zona de frontera (Admin)', {}, false, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if Player then
        -- Teletransportar a Valentine como zona segura por defecto
        TriggerClientEvent('lc-fronteras:client:rescue', src)
    end
end, 'admin')

-- Export para obtener fronteras (para el panel de administración)
exports('GetBorders', function()
    local borders = {}
    for i, border in ipairs(Config.Borders or {}) do
        local borderData = {
            name = border.name or "Frontera " .. i,
            direction = border.direction or "north",
            points = {}
        }
        
        for j, point in ipairs(border.points or {}) do
            table.insert(borderData.points, {
                x = point.x,
                y = point.y,
                z = point.z
            })
        end
        
        table.insert(borders, borderData)
    end
    
    return borders
end)
