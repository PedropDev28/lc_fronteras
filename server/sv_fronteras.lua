-- ╔══════════════════════════════════════════╗
-- ║  Desarrollado por: Fulgencio Zorongo     ║
-- ║  Compañía: La Colmena Group              ║
-- ╚══════════════════════════════════════════╝

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

RegisterNetEvent('lc-fronteras:server:logBorderCrossing')
AddEventHandler('lc-fronteras:server:logBorderCrossing', function(borderName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if Player then
        Config.Notify_Client(locale('border_crossed'), '~COLOR_RED~' .. borderName .. '~s~', 'error', 5000)
    end
end)

RSGCore.Commands.Add('rescueborder', locale('rescue_command'), {}, false, function(source)
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
            name = border.name or locale('border') .. ' ' .. i,
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
