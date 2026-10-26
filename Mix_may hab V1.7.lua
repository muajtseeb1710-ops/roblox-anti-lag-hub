
--[[
    mixmay_Hab_V1.7 Rayfield
    FPS Counter + Anti-Lag + Anti-AFK + Shadows + Mouse TP

    Removed:
    - Skybox
    - Hitbox ESP
]]

--// 1. SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[mixmay] LocalPlayer unavailable")
    return
end

local Mouse = LocalPlayer:GetMouse()

--// 2. LOAD RAYFIELD
local loaded, Rayfield = pcall(function()
    return loadstring(
        game:HttpGet("https://sirius.menu/rayfield")
    )()
end)

if not loaded or not Rayfield then
    warn("[mixmay] Failed to load Rayfield")
    return
end

--// 3. STATE
local alive = true
local lagEnabled = false
local fpsEnabled = true
local antiAfkEnabled = false
local tpEnabled = false

local desiredShadows = Lighting.GlobalShadows
local saved = {}
local connections = {}
local scanId = 0

--// 4. SAVE AND APPLY PROPERTY
local function setSaved(obj, property, value)
    if not alive then return end

    local ok, original = pcall(function()
        return obj[property]
    end)

    if not ok then return end

    if not saved[obj] then
        saved[obj] = {}
    end

    if saved[obj][property] == nil then
        saved[obj][property] = original
    end

    pcall(function()
        obj[property] = value
    end)
end

--// 5. OPTIMIZE VISUALS
local function optimize(obj)
    if not alive or not lagEnabled then return end

    pcall(function()
        if obj:IsA("BasePart") then
            setSaved(obj, "Material", Enum.Material.SmoothPlastic)
            setSaved(obj, "Reflectance", 0)

        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            setSaved(obj, "Transparency", 1)

        elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Sparkles")
            or obj:IsA("PostEffect") then

            setSaved(obj, "Enabled", false)
        end
    end)
end

--// 6. RESTORE
local function restore()
    lagEnabled = false
    scanId += 1

    for _, key in ipairs({
        "workspaceAdded",
        "lightingAdded"
    }) do
        local connection = connections[key]
        if connection then
            connection:Disconnect()
            connections[key] = nil
        end
    end

    for obj, properties in pairs(saved) do
        for property, original in pairs(properties) do
            pcall(function()
                if obj.Parent then
                    obj[property] = original
                end
            end)
        end
    end

    table.clear(saved)

    -- Respect the current Shadows toggle
    pcall(function()
        Lighting.GlobalShadows = desiredShadows
    end)
end

--// 7. ANTI-LAG
local function enableLag()
    if lagEnabled or not alive then return end

    lagEnabled = true
    scanId += 1
    local currentScan = scanId

    setSaved(Lighting, "GlobalShadows", false)
    setSaved(Lighting, "FogEnd", 100000)

    connections.workspaceAdded =
        workspace.DescendantAdded:Connect(optimize)

    connections.lightingAdded =
        Lighting.DescendantAdded:Connect(optimize)

    task.spawn(function()
        local function scan(container)
            local ok, objects = pcall(function()
                return container:GetDescendants()
            end)

            if not ok then
                warn("[mixmay] Scan failed")
                return
            end

            for i, obj in ipairs(objects) do
                if not alive
                    or not lagEnabled
                    or scanId ~= currentScan then
                    break
                end

                optimize(obj)

                if i % 100 == 0 then
                    task.wait()
                end
            end

            table.clear(objects)
        end

        scan(workspace)

        if alive and lagEnabled and scanId == currentScan then
            scan(Lighting)
        end
    end)
end

--// 8. RAYFIELD WINDOW
local Window = Rayfield:CreateWindow({
    Name = "mixmay_Hab_V1.7",
    LoadingTitle = "mixmay_Hab",
    LoadingSubtitle = "Performance Menu",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local PerformanceTab = Window:CreateTab(
    "Performance",
    "gauge"
)

local UtilityTab = Window:CreateTab(
    "Utility",
    "settings"
)

--// 9. FPS COUNTER
local FPSLabel = PerformanceTab:CreateLabel("FPS: --")

PerformanceTab:CreateToggle({
    Name = "FPS Counter",
    CurrentValue = true,
    Flag = "FPSCounter",
    Callback = function(value)
        fpsEnabled = value
        if not value then
            pcall(function()
                FPSLabel:Set("FPS Counter: OFF")
            end)
        end
    end
})

local frames = 0
local elapsed = 0

connections.render = RunService.RenderStepped:Connect(function(dt)
    if not alive or not fpsEnabled then return end

    frames += 1
    elapsed += dt

    if elapsed >= 1 then
        local fps = math.floor(frames / elapsed)

        pcall(function()
            FPSLabel:Set("FPS: " .. fps)
        end)

        frames = 0
        elapsed = 0
    end
end)

--// 10. ANTI-LAG TOGGLE
PerformanceTab:CreateToggle({
    Name = "Anti-Lag",
    CurrentValue = false,
    Flag = "AntiLag",
    Callback = function(value)
        if not alive then return end

        if value then
            enableLag()
        else
            restore()
        end
    end
})

--// 11. SHADOWS
PerformanceTab:CreateToggle({
    Name = "Shadows",
    CurrentValue = desiredShadows,
    Flag = "Shadows",
    Callback = function(value)
        desiredShadows = value

        -- Anti-Lag temporarily disables shadows
        if not lagEnabled then
            pcall(function()
                Lighting.GlobalShadows = value
            end)
        end
    end
})

--// 12. ANTI-AFK
UtilityTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(value)
        antiAfkEnabled = value
    end
})

connections.idled = LocalPlayer.Idled:Connect(function()
    if not alive or not antiAfkEnabled then return end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

--// 13. MOUSE TELEPORT
UtilityTab:CreateToggle({
    Name = "Mouse TP",
    CurrentValue = false,
    Flag = "MouseTP",
    Callback = function(value)
        tpEnabled = value
    end
})

UtilityTab:CreateLabel("Press Left Ctrl to teleport")

connections.input = UserInputService.InputBegan:Connect(
    function(input, gameProcessed)
        if not alive or gameProcessed or not tpEnabled then
            return
        end

        if input.KeyCode ~= Enum.KeyCode.LeftControl then
            return
        end

        pcall(function()
            local character = LocalPlayer.Character
            if not character then return end

            local root = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if not root or not humanoid or humanoid.Health <= 0 then
                return
            end

            local target = Mouse.Hit.Position
            root.CFrame = CFrame.new(
                target + Vector3.new(0, 2.5, 0)
            )
        end)
    end
)

--// 14. SHUTDOWN
local function cleanup()
    if not alive then return end

    alive = false
    antiAfkEnabled = false
    tpEnabled = false
    fpsEnabled = false

    restore()

    for _, connection in pairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(connections)

    pcall(function()
        Rayfield:Destroy()
    end)
end

UtilityTab:CreateButton({
    Name = "Close / Restore",
    Callback = cleanup
})

print("[mixmay] V1.7 Rayfield loaded")
