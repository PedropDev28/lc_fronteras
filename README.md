# LC Fronteras - Sistema de Control de Fronteras

## Descripción
Sistema avanzado de control de fronteras que permite definir límites en el mapa mediante vectores. Cuando un jugador intenta cruzar una frontera prohibida, es teletransportado a una zona de ejecución donde un pelotón de fusilamiento (30+ NPCs) le dispara.

## Características
- ✅ Definición de fronteras mediante vectores personalizables
- ✅ Sistema de oscurecimiento visual que oculta áreas fuera de las fronteras
- ✅ Advertencias progresivas al acercarse a las fronteras
- ✅ Teletransporte automático a zona de ejecución
- ✅ Pelotón de fusilamiento con 30+ NPCs armados
- ✅ Sistema de detección de dirección (norte, sur, este, oeste)
- ✅ **Modo Debug Visual** con líneas rojas y markers en el mapa
- ✅ Comando en tiempo real para activar/desactivar debug
- ✅ Comando de rescate para administradores
- ✅ Totalmente configurable

## Instalación
1. Copia la carpeta `lc_fronteras` en tu carpeta de recursos
2. Añade `ensure lc_fronteras` en tu `server.cfg`
3. Reinicia el servidor

## Dependencias
- `rsg-core` - Framework principal
- `ox_lib` - Sistema de locales y notificaciones

## Configuración de Fronteras

### Cómo funcionan las fronteras
Cada frontera se define mediante una serie de puntos (vectores) que forman una línea. El sistema detecta:
- La distancia del jugador a cada segmento de línea
- En qué lado de la línea se encuentra el jugador
- Si ha cruzado hacia el lado "prohibido"

### Estructura de una frontera
```lua
{
    name = "Nombre de la Frontera",
    points = {
        vector3(x1, y1, z1),
        vector3(x2, y2, z2),
        vector3(x3, y3, z3),
        -- más puntos...
    },
    direction = "north", -- Dirección prohibida
}
```

### Direcciones disponibles
- `"north"` - Prohibe cruzar hacia el norte
- `"south"` - Prohibe cruzar hacia el sur
- `"east"` - Prohibe cruzar hacia el este
- `"west"` - Prohibe cruzar hacia el oeste

### Ejemplo: Crear una frontera personalizada

#### 1. Obtener coordenadas en el juego
Usa el comando `/getcoords` o cualquier herramienta de coordenadas para obtener los puntos de tu frontera.

#### 2. Añadir la frontera en config.lua
```lua
Config.Borders = {
    {
        name = "Frontera de Blackwater",
        points = {
            vector3(-800.0, -1300.0, 43.0),
            vector3(-750.0, -1250.0, 45.0),
            vector3(-700.0, -1200.0, 47.0),
            vector3(-650.0, -1150.0, 50.0),
        },
        direction = "west", -- No permitir cruzar hacia el oeste
    },
}
```

#### 3. Consejos para crear fronteras efectivas
- **Usa múltiples puntos**: Más puntos = frontera más precisa
- **Puntos cercanos**: Distancia recomendada entre puntos: 50-100 metros
- **Altura (Z)**: Ajusta la Z según el terreno para evitar problemas
- **Prueba la dirección**: Testea en el juego para asegurarte de que la dirección es correcta

### Cómo determinar la dirección correcta
1. Colócate en el lado "seguro" del mapa
2. Mira hacia donde quieres prohibir el paso
3. Usa esa dirección (north/south/east/west)

Ejemplo: Si estás en Valentine y quieres prohibir que vayan hacia Ambarino (norte):
- Dirección: `"north"`
- Los jugadores pueden estar en Valentine
- Si cruzan hacia Ambarino = capturados

## Configuración de la Zona de Ejecución

```lua
Config.ExecutionZone = {
    coords = vector3(-1000.0, -1000.0, 50.0), -- Dónde aparece el jugador
    heading = 0.0,                             -- Orientación del jugador
    npcCount = 30,                             -- Número de NPCs (30+)
    npcModel = 'cs_mp_travellingsaleswoman',   -- Modelo de NPC
    npcWeapon = 'WEAPON_RIFLE_SPRINGFIELD',    -- Arma de los NPCs
    spawnRadius = 15.0,                        -- Radio del círculo de NPCs
    killDelay = 3000                           -- Delay antes de disparar (ms)
}
```

### Modelos de NPC recomendados para pelotón
- `'s_m_m_unigunslinger_01'` - Pistolero del ejército
- `'s_m_m_unimilitia_01'` - Milicia
- `'u_m_m_bht_banditoshoot'` - Bandido
- `'cs_creoleguy'` - Civil armado
- `'s_m_y_army_01'` - Soldado

### Armas recomendadas
- `'WEAPON_RIFLE_SPRINGFIELD'` - Rifle Springfield
- `'WEAPON_RIFLE_BOLTACTION'` - Rifle de cerrojo
- `'WEAPON_REPEATER_CARBINE'` - Carabina repetidora
- `'WEAPON_RIFLE_VARMINT'` - Rifle Varmint
- `'WEAPON_REVOLVER_CATTLEMAN'` - Revólver Cattleman

## Configuración de Efectos Visuales

```lua
Config.Fog = {
    Enabled = true,           -- Activar/desactivar oscurecimiento
    Density = 0.9,            -- Densidad (0.0 - 1.0)
    Distance = 100.0,         -- Distancia desde frontera
    Color = {r = 200, g = 200, b = 200} -- Color RGB (no usado actualmente)
}
```

**Nota**: El sistema ahora usa oscurecimiento de pantalla con efectos de timecycle en lugar de niebla tradicional para mejor rendimiento.

## Modo Debug Visual

### ¿Qué es el Modo Debug?
El modo debug te permite visualizar exactamente dónde están tus fronteras en el juego. Es **esencial** para configurar correctamente las fronteras.

### Activar Modo Debug

**Opción 1: En config.lua (permanente)**
```lua
Config.DebugMode = true
```

**Opción 2: Comando en el juego (temporal)**
```
/fronterasdebug
```

### ¿Qué muestra el Modo Debug?

Cuando está activado verás:

1. **Líneas Rojas**: Conectan cada punto de la frontera
   - Las líneas son visibles en el mundo 3D
   - Color rojo intenso para fácil identificación

2. **Markers Cilíndricos Rojos**: En cada punto de la frontera
   - Cilindros rojos semi-transparentes de 2m de diámetro
   - Altura de 5m para verlos desde lejos

3. **Blips en el Mapa**: Marcadores en cada punto
   - Aparecen en el mapa como puntos
   - Etiquetados con "Nombre Frontera - Punto X"

4. **Información en Pantalla**: Esquina superior izquierda
   ```
   DEBUG MODE
   Frontera más cercana: Frontera Norte
   Distancia: 25.43m
   Distancia de captura: 50.00m
   ```

### Cómo Usar el Modo Debug

**Paso 1: Activar el modo**
```
/fronterasdebug
```
Verás: "Modo Debug ACTIVADO"

**Paso 2: Vuela o camina hacia tus fronteras**
- Usa un vehículo o noclip para moverte rápido
- Las líneas rojas te mostrarán exactamente dónde está cada frontera

**Paso 3: Ajusta las coordenadas**
- Si la frontera no está donde quieres, anota las coordenadas correctas
- Edita `config.lua` con los nuevos puntos
- Reinicia el recurso: `restart lc_fronteras`

**Paso 4: Verificar dirección**
- Acércate a la frontera
- Cruza hacia el lado que quieres prohibir
- Si te captura = dirección correcta ✅
- Si NO te captura = cambia la dirección en config.lua ❌

**Paso 5: Desactivar cuando termines**
```
/fronterasdebug
```
Verás: "Modo Debug DESACTIVADO"

### Ejemplo de Uso del Debug

```lua
-- 1. Activa debug en config.lua
Config.DebugMode = true

-- 2. Entra al juego y mira el mapa
-- Verás los blips de tus fronteras

-- 3. Vuela hacia una frontera
-- Verás las líneas rojas conectando los puntos

-- 4. Observa la información en pantalla:
-- "Distancia: 5.23m" - Muy cerca!
-- "Distancia de captura: 50.00m" - Todavía no te capturará

-- 5. Cruza la línea roja hacia el lado "prohibido"
-- ¿Te capturó? = Dirección correcta
-- ¿No te capturó? = Dirección incorrecta, cambiar en config
```

### Consejos para Configurar Fronteras con Debug

1. **Usa un punto de referencia**: Comienza con 2 puntos simples
   ```lua
   points = {
       vector3(100.0, 200.0, 50.0),
       vector3(200.0, 200.0, 50.0),
   },
   ```

2. **Verifica en el mapa**: Con debug activado, ve al mapa y busca los blips

3. **Añade más puntos gradualmente**: Una vez que los 2 primeros funcionen, añade más

4. **Mantén la misma altura (Z)**: Si el terreno es plano, usa la misma Z en todos los puntos

5. **Distancia entre puntos**: 50-100 metros es ideal para líneas rectas

## Comandos

### `/fronterasdebug`
Activa o desactiva el modo debug visual en tiempo real.
- No requiere permisos especiales
- Toggle on/off
- Útil para configurar fronteras

```
/fronterasdebug
```

### `/rescueborder` (Solo Admin)
Rescata a un jugador que está atrapado en la zona de ejecución y lo teletransporta a Valentine.

```
/rescueborder
```

## Parámetros Ajustables

### Distancias y Tiempos
```lua
Config.CheckDistance = 50.0      -- Distancia de detección (metros)
Config.CheckInterval = 1000      -- Intervalo de verificación (ms)
```

- `CheckDistance`: A qué distancia de la frontera empieza a detectar
- `CheckInterval`: Cada cuánto verifica (1000ms = 1 segundo)

⚠️ **Nota**: Valores muy bajos en `CheckInterval` pueden causar lag

## Troubleshooting

### La frontera no funciona
1. Verifica que los puntos estén en el orden correcto
2. Comprueba que la dirección sea la adecuada
3. Aumenta `Config.CheckDistance` para mayor rango de detección

### Los NPCs no disparan
1. Verifica que el modelo de NPC sea válido
2. Comprueba que el arma exista en tu servidor
3. Aumenta `Config.ExecutionZone.killDelay` si necesitan más tiempo

### Lag o rendimiento bajo
1. Reduce `Config.ExecutionZone.npcCount` (menos NPCs)
2. Aumenta `Config.CheckInterval` (verifica menos frecuentemente)
3. Desactiva la niebla: `Config.Fog.Enabled = false`

### La niebla no aparece
1. Verifica que `Config.Fog.Enabled = true`
2. Ajusta `Config.Fog.Distance` (mayor = empieza más lejos)
3. Aumenta `Config.Fog.Density` (más opaca)

## Ejemplos de Configuración

### Frontera simple (línea recta)
```lua
{
    name = "Muro del Norte",
    points = {
        vector3(-2000.0, 2000.0, 100.0),
        vector3(2000.0, 2000.0, 100.0),
    },
    direction = "north",
}
```

### Frontera compleja (curva)
```lua
{
    name = "Frontera Este Curva",
    points = {
        vector3(3000.0, -2000.0, 100.0),
        vector3(3100.0, -1500.0, 110.0),
        vector3(3200.0, -1000.0, 115.0),
        vector3(3300.0, -500.0, 120.0),
        vector3(3400.0, 0.0, 125.0),
        vector3(3500.0, 500.0, 130.0),
        vector3(3600.0, 1000.0, 135.0),
    },
    direction = "east",
}
```

### Zona de ejecución extrema
```lua
Config.ExecutionZone = {
    coords = vector3(-5000.0, -5000.0, 50.0),
    heading = 0.0,
    npcCount = 50,  -- 50 NPCs!
    npcModel = 's_m_m_unigunslinger_01',
    npcWeapon = 'WEAPON_RIFLE_SPRINGFIELD',
    spawnRadius = 20.0,  -- Círculo más grande
    killDelay = 2000     -- Disparan más rápido
}
```

## Localización

Edita los archivos en `locales/` para cambiar los mensajes:

**es.json** (Español)
```json
{
    "border_warning": "⚠️ Advertencia: Te estás acercando a una frontera prohibida",
    "border_crossed": "❌ Has cruzado una frontera ilegal",
    "execution_message": "Los guardias fronterizos te han capturado"
}
```

**en.json** (English)
```json
{
    "border_warning": "⚠️ Warning: You are approaching a forbidden border",
    "border_crossed": "❌ You have crossed an illegal border",
    "execution_message": "Border guards have captured you"
}
```

## Créditos
- **Desarrollado por**: Fulgencio Zorongo
- **Compañía**: La Colmena Group
- **Versión**: 1.0.0

## Soporte
Para soporte, reportar bugs o sugerencias, contacta a La Colmena Group.

---

**⚠️ IMPORTANTE**: Este recurso es para uso de roleplay. Asegúrate de que todos los jugadores sean conscientes de las fronteras establecidas en tu servidor.
