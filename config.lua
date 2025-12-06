-- ╔══════════════════════════════════════════╗
-- ║  Desarrollado por: Fulgencio Zorongo     ║
-- ║  Compañía: La Colmena Group              ║
-- ╚══════════════════════════════════════════╝
lib.locale()
Config = {}

-- Modo Debug para visualizar fronteras
Config.DebugMode = false -- Cambia a true para ver las líneas de las fronteras

-- Distancia de verificación de fronteras (metros)
Config.CheckDistance = 50.0

-- Intervalo de verificación (milisegundos)
Config.CheckInterval = 1000

-- Configuración de niebla
Config.Fog = {
    Enabled = true,
    Density = 0.9,                        -- Densidad de la niebla (0.0 - 1.0)
    Distance = 100.0,                     -- Distancia a la que empieza la niebla desde la frontera
    Color = { r = 200, g = 200, b = 200 } -- Color de la niebla (RGB)
}

-- Zona de ejecución (donde aparecerán los pelotones de fusilamiento)
Config.ExecutionZone = {
    coords = vector3(-44.83, 1739.40, 176.59), -- Coordenadas donde se teletransporta al jugador
    heading = 180.0,
    npcCount = 30,                              -- Número de NPCs
    npcModel = 'mes_sadie4_males_01',           -- Modelo de NPC (cambia por el que prefieras)
    npcWeapon = 'WEAPON_RIFLE_SPRINGFIELD',     -- Arma de los NPCs
    spawnRadius = 10.0,                         -- Radio en el que se spawnnean los NPCs alrededor del jugador
    killDelay = 3000                            -- Delay antes de que empiecen a disparar (ms)
}

-- Definición de fronteras
-- Cada frontera es una línea entre dos puntos (vector3)
-- El sistema detecta si el jugador cruza esta línea
Config.Borders = {
    -- Ejemplo: Frontera Norte (New Hanover - Ambarino)
    {
        name = locale('border_1'),
        points = {
            vector3(-2146.42, 1084.00, 213.67),
            vector3(-1481.42, 861.65, 163.64),
            vector3(-1005.81, 496.91, 62.35),
        },
        direction = "north", -- Dirección prohibida: north, south, east, west
    },

    -- Ejemplo: Frontera Sur
    {
        name = locale('border_2'),
        points = {
            vector3(-1005.81, 496.91, 62.35),
            vector3(-637.19, 903.82, 74.78),
            vector3(-261.18, 1435.60, 103.84),
            vector3(581.94, 1842.69, 164.23)            
        },
        direction = "south",
    },

    -- Ejemplo: Frontera Este
    {
        name = locale('border_3'),
        points = {
            vector3(581.94, 1842.69, 164.23),
            vector3(809.97, 1509.38, 205.11),
            vector3(822.93, 1025.87, 119.48),
        },
        direction = "north",
    },

    -- Ejemplo: Frontera Oeste
    {
        name = locale('border_4'),
        points = {
            vector3(822.93, 1025.87, 119.48),
            vector3(1458.55, 882.56, 115.50),
            vector3(1918.67, 962.65, 117.31),
            vector3(1630.12, 118.22, 83.07),
            vector3(1977.77, -276.06, 41.89),
            vector3(1883.59, 496.44, 118.89),
            vector3(2766.38, 118.03, 49.95),
        },
        direction = "north",
    },

    {
        name = locale('border_5'),
        points = {
            vector3(-2336.91, -1991.31, 108.97),
            vector3(-1359.35, -2025.61, 42.62),
        },
        direction = "south",
    },
}