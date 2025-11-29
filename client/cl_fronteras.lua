-- ╔══════════════════════════════════════════╗
-- ║  Desarrollado por: Fulgencio Zorongo     ║
-- ║  Compañía: La Colmena Group              ║
-- ╚══════════════════════════════════════════╝

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local isCaptured = false
local lastWarningTime = 0
local warningCooldown = 10000 -- 10 segundos entre advertencias
local debugMarkers = {}       -- Tabla para almacenar markers de debug

-- Función para calcular la distancia de un punto a una línea
local function distanceToLineSegment(point, lineStart, lineEnd)
    local px, py = point.x, point.y
    local x1, y1 = lineStart.x, lineStart.y
    local x2, y2 = lineEnd.x, lineEnd.y

    local dx = x2 - x1
    local dy = y2 - y1

    if dx == 0 and dy == 0 then
        return math.sqrt((px - x1) ^ 2 + (py - y1) ^ 2)
    end

    local t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
    t = math.max(0, math.min(1, t))

    local nearestX = x1 + t * dx
    local nearestY = y1 + t * dy

    return math.sqrt((px - nearestX) ^ 2 + (py - nearestY) ^ 2)
end

-- Función para determinar si el jugador está en el lado prohibido de la frontera
local function isOnForbiddenSide(playerCoords, lineStart, lineEnd, direction)
    local px, py = playerCoords.x, playerCoords.y
    local x1, y1 = lineStart.x, lineStart.y
    local x2, y2 = lineEnd.x, lineEnd.y

    -- Calcular el vector perpendicular a la línea
    local dx = x2 - x1
    local dy = y2 - y1

    -- Vector del punto de inicio de la línea al jugador
    local toPx = px - x1
    local toPy = py - y1

    -- Producto cruzado para determinar de qué lado está
    local cross = dx * toPy - dy * toPx

    if direction == "north" then
        return cross > 0 -- Lado norte
    elseif direction == "south" then
        return cross < 0 -- Lado sur
    elseif direction == "east" then
        -- Para este/oeste usamos comparación directa de coordenadas
        return px > x1
    elseif direction == "west" then
        return px < x1
    end

    return false
end

-- Función para verificar si el jugador está cerca o ha cruzado una frontera
local function checkBorders()
    if isCaptured then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, border in ipairs(Config.Borders) do
        for i = 1, #border.points - 1 do
            local lineStart = border.points[i]
            local lineEnd = border.points[i + 1]

            local distance = distanceToLineSegment(playerCoords, lineStart, lineEnd)

            -- Si está muy cerca de la frontera
            if distance < Config.CheckDistance then
                local onForbiddenSide = isOnForbiddenSide(playerCoords, lineStart, lineEnd, border.direction)

                if onForbiddenSide then
                    -- Ha cruzado la frontera - teletransportar a zona de ejecución
                    TriggerEvent('lc-fronteras:client:capturePlayer', border.name)
                    return
                elseif distance < 30.0 then
                    -- Advertencia si está muy cerca pero no ha cruzado
                    local currentTime = GetGameTimer()
                    if currentTime - lastWarningTime > warningCooldown then
                        Config.Notify_Client(locale('border_system'), locale('last_warning'), 'error', 5000)
                        lastWarningTime = currentTime
                    end
                end
            end
        end
    end
end

-- Thread principal para verificar fronteras
Citizen.CreateThread(function()
    while true do
        Wait(Config.CheckInterval)
        checkBorders()
    end
end)

-- Evento para capturar al jugador
RegisterNetEvent('lc-fronteras:client:capturePlayer')
AddEventHandler('lc-fronteras:client:capturePlayer', function(borderName)
    if isCaptured then return end
    isCaptured = true

    local playerPed = PlayerPedId()

    Config.Notify_Client(locale('trespassing'), locale('border_crossed'), 'error', 5000)

    -- Teletransportar al jugador directamente sin fade
    SetEntityCoords(playerPed, Config.ExecutionZone.coords.x, Config.ExecutionZone.coords.y,
        Config.ExecutionZone.coords.z, false, false, false, false)
    SetEntityHeading(playerPed, Config.ExecutionZone.heading)

    -- Forzar al jugador a estar en el suelo
    Citizen.InvokeNative(0x9587913B9E772D29, playerPed, true) -- FREEZE_ENTITY_POSITION
    Wait(500)
    Citizen.InvokeNative(0x9587913B9E772D29, playerPed, false)

    Config.Notify_Client(locale('border_system'), locale('execution_message'), 'error', 5000)

    -- Spawn NPCs de fusilamiento
    Wait(1000)
    TriggerEvent('lc-fronteras:client:spawnExecutionSquad')

    -- Resetear después de un tiempo
    Wait(30000) -- 30 segundos
    isCaptured = false
end)

-- Spawn del pelotón de fusilamiento
RegisterNetEvent('lc-fronteras:client:spawnExecutionSquad')
AddEventHandler('lc-fronteras:client:spawnExecutionSquad', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local npcModel = GetHashKey(Config.ExecutionZone.npcModel)
    local weaponHash = GetHashKey(Config.ExecutionZone.npcWeapon)

    -- Cargar modelo de NPC
    RequestModel(npcModel)
    local timeout = 0
    while not HasModelLoaded(npcModel) do
        Wait(100)
        timeout = timeout + 1
        if timeout > 50 then -- 5 segundos timeout
            print('[LC-FRONTERAS] Error: No se pudo cargar el modelo ' .. Config.ExecutionZone.npcModel)
            return
        end
    end

    -- No necesitamos cargar el arma en RDR2, ya está disponible
    -- El sistema de armas funciona diferente que en GTA

    local npcs = {}

    -- Crear NPCs en círculo alrededor del jugador
    for i = 1, Config.ExecutionZone.npcCount do
        local angle = (i / Config.ExecutionZone.npcCount) * 2 * math.pi
        local spawnX = playerCoords.x + math.cos(angle) * Config.ExecutionZone.spawnRadius
        local spawnY = playerCoords.y + math.sin(angle) * Config.ExecutionZone.spawnRadius
        local spawnZ = playerCoords.z

        -- Crear ped usando native de RDR2
        local npc = Citizen.InvokeNative(0xD49F9B0955C367DE, npcModel, spawnX, spawnY, spawnZ, 0.0, true, true, true,
            true) -- CREATE_PED

        if DoesEntityExist(npc) then
            -- Hacer visible y sólido
            SetEntityVisible(npc, true)
            SetEntityAlpha(npc, 255, false)
            Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SET_RANDOM_OUTFIT_VARIATION

            -- Configurar como invencible temporalmente
            SetEntityInvincible(npc, false)
            SetEntityAsMissionEntity(npc, true, true)
            SetBlockingOfNonTemporaryEvents(npc, true)

            -- Colocar en el suelo correctamente
            PlaceEntityOnGroundProperly(npc)

            -- Dar arma usando native de RDR2
            Citizen.InvokeNative(0x5E3BDDBCB83F3D84, npc, weaponHash, 500, true, 1, 0, 0.5, 1.0, 752097756, false, 0.0,
                false) -- GIVE_WEAPON_TO_PED
            SetCurrentPedWeapon(npc, weaponHash, true, 0, false, false)

            -- Hacer que mire al jugador
            TaskTurnPedToFaceEntity(npc, playerPed, -1)

            -- Configurar relación como enemigo
            Citizen.InvokeNative(0xD8544F6260F5F01E, npc, playerPed) -- _SET_PED_AS_ENEMY
            SetPedRelationshipGroupHash(npc, GetHashKey('COP'))
            SetRelationshipBetweenGroups(5, GetHashKey('COP'), GetHashKey('PLAYER'))

            table.insert(npcs, npc)
        end
    end

    -- Esperar antes de empezar a disparar
    Wait(Config.ExecutionZone.killDelay)

    -- Hacer que todos disparen al jugador
    for _, npc in ipairs(npcs) do
        if DoesEntityExist(npc) then
            -- Configurar atributos de combate para RDR2
            Citizen.InvokeNative(0x9F7794730795E019, npc, 46, true) -- SET_PED_COMBAT_ATTRIBUTES (Always fight)
            Citizen.InvokeNative(0x9F7794730795E019, npc, 5, true)  -- (Can use cover)
            Citizen.InvokeNative(0x9F7794730795E019, npc, 1, false) -- (Can do drivebys)
            Citizen.InvokeNative(0xCE7DE4B56BC8F774, npc, 100.0)    -- SET_PED_COMBAT_RANGE

            -- Hacer que ataque al jugador
            TaskCombatPed(npc, playerPed, 0, 16)
        end
    end

    -- Limpiar NPCs después de un tiempo
    Wait(60000) -- 60 segundos
    for _, npc in ipairs(npcs) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end

    SetModelAsNoLongerNeeded(npcModel)
end)

-- Sistema de oscurecimiento para ocultar áreas fuera de fronteras
local darknessEffect = false
local fowEnabled = true -- Por defecto, FOW está habilitado

-- Thread para mantener FOW en zonas prohibidas
Citizen.CreateThread(function()
    -- Habilitar FOW al inicio para que las zonas no exploradas se vean con niebla
    Citizen.InvokeNative(0x5FBCA48327B914DF, true) -- SetMinimapHideFow(true) - Muestra FOW
    fowEnabled = true
end)

if Config.Fog.Enabled then
    Citizen.CreateThread(function()
        while true do
            Wait(100) -- Optimizado para evitar lag

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local closestDistance = 999999
            local playerOnForbiddenSide = false

            -- Verificar distancia a todas las fronteras y si está del lado prohibido
            for _, border in ipairs(Config.Borders) do
                for i = 1, #border.points - 1 do
                    local lineStart = border.points[i]
                    local lineEnd = border.points[i + 1]
                    local distance = distanceToLineSegment(playerCoords, lineStart, lineEnd)

                    if distance < closestDistance then
                        closestDistance = distance
                    end

                    -- Verificar si está del lado prohibido
                    if distance < Config.Fog.Distance then
                        local forbidden = isOnForbiddenSide(playerCoords, lineStart, lineEnd, border.direction)
                        if forbidden then
                            playerOnForbiddenSide = true
                        end
                    end
                end
            end

            -- Si está del lado prohibido, aplicar oscuridad
            if playerOnForbiddenSide and closestDistance < Config.Fog.Distance then
                local darknessIntensity = 1.0 - (closestDistance / Config.Fog.Distance)
                darknessIntensity = math.max(0.0, math.min(1.0, darknessIntensity))

                if not darknessEffect then
                    darknessEffect = true
                end

                -- Aplicar efecto visual para oscurecer (solo timecycle básico)
                Citizen.InvokeNative(0xFDB74C9CC90DDEC, 'MP_Massacre_Melee')                     -- SET_TIMECYCLE_MODIFIER
                Citizen.InvokeNative(0xFDF3D97C674AFB66, darknessIntensity * Config.Fog.Density) -- SET_TIMECYCLE_MODIFIER_STRENGTH
            else
                -- Limpiar efectos
                if darknessEffect then
                    darknessEffect = false
                    Citizen.InvokeNative(0x0F07E7745A236711) -- CLEAR_TIMECYCLE_MODIFIER
                end
            end

            -- Mantener FOW siempre habilitado para que las zonas prohibidas se vean con niebla
            if not fowEnabled then
                Citizen.InvokeNative(0x5FBCA48327B914DF, true) -- SetMinimapHideFow(true)
                fowEnabled = true
            end
        end
    end)
end

-- Evento para rescatar al jugador (comando admin)
RegisterNetEvent('lc-fronteras:client:rescue')
AddEventHandler('lc-fronteras:client:rescue', function()
    local playerPed = PlayerPedId()
    isCaptured = false

    -- Teletransportar a Valentine (zona segura)
    SetEntityCoords(playerPed, -175.0, 627.0, 114.0, false, false, false, false)
    SetEntityHeading(playerPed, 90.0)

    Config.Notify_Client(locale('border_system'), 'Has sido rescatado por un administrador', 'success', 5000)
end)

Citizen.CreateThread(function()
    for borderIndex, border in ipairs(Config.Borders) do
        for pointIndex, point in ipairs(border.points) do
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, point.x, point.y, point.z)
            SetBlipSprite(blip, GetHashKey('blip_ambient_companion'), true)
            SetBlipScale(blip, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, string.format('%s - Punto %d', border.name, pointIndex))
            table.insert(debugMarkers, blip)
        end
    end
end)
-- Sistema de Debug Visual para fronteras
if Config.DebugMode then
    -- Crear markers para visualizar los puntos de las fronteras


    -- Dibujar líneas entre los puntos de las fronteras
    Citizen.CreateThread(function()
        while true do
            Wait(0)

            for _, border in ipairs(Config.Borders) do
                for i = 1, #border.points - 1 do
                    local start = border.points[i]
                    local endPoint = border.points[i + 1]

                    -- Dibujar línea roja entre puntos
                    Citizen.InvokeNative(
                        0x2A27F1D96F204F52, -- DrawLine
                        start.x, start.y, start.z,
                        endPoint.x, endPoint.y, endPoint.z,
                        255, 0, 0, 255 -- Color rojo
                    )

                    -- Dibujar markers en cada punto
                    Citizen.InvokeNative(
                        0x2A32FAA57B937173, -- DrawMarker
                        0x94FDAE17,         -- Marker tipo cilindro
                        start.x, start.y, start.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        2.0, 2.0, 5.0,  -- Tamaño
                        255, 0, 0, 100, -- Color rojo semi-transparente
                        false, false, 2, false, 0, 0, false
                    )
                end
            end

            -- Mostrar información de debug
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local closestBorder = nil
            local closestDistance = 999999

            for _, border in ipairs(Config.Borders) do
                for i = 1, #border.points - 1 do
                    local distance = distanceToLineSegment(playerCoords, border.points[i], border.points[i + 1])
                    if distance < closestDistance then
                        closestDistance = distance
                        closestBorder = border.name
                    end
                end
            end

            -- Dibujar texto en pantalla con información
            local str = string.format(
                '~COLOR_RED~DEBUG MODE~s~\n' ..
                'Frontera más cercana: ~COLOR_YELLOW~%s~s~\n' ..
                'Distancia: ~COLOR_YELLOW~%.2fm~s~\n' ..
                'Distancia de captura: ~COLOR_RED~%.2fm~s~',
                closestBorder or 'Ninguna',
                closestDistance,
                Config.CheckDistance
            )

            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 255)
            SetTextCentre(false)
            DisplayText(CreateVarString(10, 'LITERAL_STRING', str), 0.02, 0.02)
        end
    end)
end

-- Comando para activar/desactivar debug mode en tiempo real
RegisterCommand('fronterasdebug', function()
    Config.DebugMode = not Config.DebugMode

    if Config.DebugMode then
        Config.Notify_Client(locale('border_system'), 'Modo Debug ~COLOR_GREEN~ACTIVADO~s~', 'success', 5000)
        -- Limpiar markers anteriores
        for _, blip in ipairs(debugMarkers) do
            RemoveBlip(blip)
        end
        debugMarkers = {}

        -- Crear nuevos markers
        for borderIndex, border in ipairs(Config.Borders) do
            for pointIndex, point in ipairs(border.points) do
                local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, point.x, point.y, point.z)
                SetBlipSprite(blip, GetHashKey('blip_ambient_companion'), true)
                SetBlipScale(blip, 0.2)
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, string.format('%s - Punto %d', border.name, pointIndex))
                table.insert(debugMarkers, blip)
            end
        end
    else
        Config.Notify_Client(locale('border_system'), 'Modo Debug ~COLOR_RED~DESACTIVADO~s~', 'error', 5000)
        -- Limpiar markers
        for _, blip in ipairs(debugMarkers) do
            RemoveBlip(blip)
        end
        debugMarkers = {}
    end
end, false)

-- Cleanup al detener el recurso
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Limpiar efectos visuales
    Citizen.InvokeNative(0x0F07E7745A236711) -- CLEAR_TIMECYCLE_MODIFIER

    -- Restaurar Fog of War en el minimapa
    Citizen.InvokeNative(0x5FBCA48327B914DF, true) -- SetMinimapHideFow

    -- Limpiar markers de debug
    for _, blip in ipairs(debugMarkers) do
        RemoveBlip(blip)
    end
    debugMarkers = {}
end)
