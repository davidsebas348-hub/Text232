-- ===== SERVICES =====
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- ===== TOGGLE =====
if _G.AUTO_JUMP_CLICK then
    -- Si ya está activo, desactivar
    _G.AUTO_JUMP_CLICK = false
    return
end
_G.AUTO_JUMP_CLICK = true

-- ===== PLAYER =====
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local LocalPlayer = player

-- CONFIGURACIÓN DEL CLICK
local OFFSET_X = 15       -- mover a la derecha
local OFFSET_Y = 30       -- mover hacia abajo
local CLICK_DURATION = 0.05 -- tiempo que mantiene presionado el click

-- Buscar JumpButton
local function getJumpButton()
    return playerGui:FindFirstChild("JumpButton", true)
end

-- Función para simular click
local function clickButton(button)
    if not button then return end
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize

    local x = absPos.X + absSize.X / 2 + OFFSET_X
    local y = absPos.Y + absSize.Y / 2 + OFFSET_Y

    -- PRESIONAR
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(CLICK_DURATION)
    -- SOLTAR
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

-- Obtener el modelo del jugador en Workspace.Live
local function getMyModel()
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return nil end
    return liveFolder:FindFirstChild(LocalPlayer.Name)
end

-- Tabla para controlar hits existentes
local recentHits = {}

-- Función para actualizar hits y hacer click por cada nuevo
local function updateHits()
    if not _G.AUTO_JUMP_CLICK then return end -- detener si toggle es false

    local myModel = getMyModel()
    if not myModel then
        recentHits = {}
        return
    end

    for _, child in ipairs(myModel:GetChildren()) do
        if child.Name == "RecentM1Hit" and not recentHits[child] then
            recentHits[child] = true
            -- ¡Nuevo hit detectado! Ejecutar click
            clickButton(getJumpButton())
        end
    end

    -- Limpiar hits que desaparecieron
    for hit,_ in pairs(recentHits) do
        if not hit.Parent then
            recentHits[hit] = nil
        end
    end
end

-- Conexión a Heartbeat para detectar hits cada frame
RunService.Heartbeat:Connect(function()
    updateHits()
end)
