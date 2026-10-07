-- ==================================================
-- Real Script Hub v2 — ULTIMATE EDITION
-- รวม: รหัสผ่าน 1710 | ความเร็ว | จมดิน+คีย์ลัด B | ESP | FPS มุมขวาบน | Anti-Lag | Fullbright
-- ทำงานบนตัวรัน Real ✅
-- ==================================================

-- โหลดไลบรารี
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- บริการระบบ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera

-- ==================================================
-- 0. ระบบแสดง FPS มุมขวาบน (ทำงานตลอดเวลา)
-- ==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RealtimeFPSDisplay"
ScreenGui.ResetOnSpawn = false

-- ป้องกันหลุด เข้ากับ Real และตัวรันทั่วไป
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 130, 0, 36)
Frame.Position = UDim2.new(1, -15, 0, 15)
Frame.AnchorPoint = Vector2.new(1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(70, 70, 70)
UIStroke.Parent = Frame

local FPSText = Instance.new("TextLabel")
FPSText.Parent = Frame
FPSText.Size = UDim2.new(1, 0, 1, 0)
FPSText.BackgroundTransparency = 1
FPSText.Font = Enum.Font.SourceSansBold
FPSText.TextSize = 17
FPSText.Text = "⚡ FPS: --"

-- คำนวณ FPS แบบเรียลไทม์
local lastUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastUpdate >= 0.25 then
        local fps = math.floor(frameCount / (now - lastUpdate))
        FPSText.Text = "⚡ FPS: " .. fps
        
        -- เปลี่ยนสีตามความลื่น
        if fps >= 50 then
            FPSText.TextColor3 = Color3.fromRGB(0, 255, 127)  -- เขียว = ลื่น
        elseif fps >= 30 then
            FPSText.TextColor3 = Color3.fromRGB(255, 200, 0)  -- เหลือง = ปานกลาง
        else
            FPSText.TextColor3 = Color3.fromRGB(255, 60, 60)   -- แดง = กระตุก
        end
        
        frameCount = 0
        lastUpdate = now
    end
end)

-- ==================================================
-- 1. หน้าต่างหลัก + รหัสผ่าน 1710
-- ==================================================
local Window = Rayfield:CreateWindow({
   Name = "Real Script Hub v2",
   LoadingTitle = "กำลังโหลดระบบ...",
   LoadingSubtitle = "ทำงานบน Real ✅",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RealHubConfig",
      FileName = "MainConfig"
   },
   Discord = { Enabled = false },
   KeySystem = true,
   KeySettings = {
      Title = "🔐 เข้าสู่ระบบ",
      Subtitle = "กรุณาใส่รหัสผ่าน",
      Note = "รหัส: 1710 | จดจำอัตโนมัติ",
      Key = {"1710"},
      SaveKey = true,
      SaveFolder = "RealHubKey",
      SaveName = "access_key"
   }
})

-- ตัวแปรหลัก
local currentWalkSpeed = 16
local currentJumpPower = 50
local loopSpeedConnection = nil
local antiAfkConnection = nil
local hideLoop = nil
local originalTransparency = {}
local isHiddenActive = false
local targetDepthOffset = 0
local espObjects = {}
local espLoop = nil
local playerAddedConnection = nil
local antiLagConnection = nil
local fullbrightLoop = nil
local isAntiLagActive = false
local isFullbrightActive = false

----------------------------------------------------
-- 2. แท็บความเร็ว
----------------------------------------------------
local SpeedTab = Window:CreateTab("ตั้งค่าความเร็ว", 4483362458)

SpeedTab:CreateSlider({
   Name = "ความเร็วการเดิน (WalkSpeed)",
   Range = {16, 300},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
       currentWalkSpeed = Value
       local char = LocalPlayer.Character
       if char and char:FindFirstChild("Humanoid") then
           char.Humanoid.WalkSpeed = Value
       end
   end,
})

SpeedTab:CreateSlider({
   Name = "แรงกระโดด (JumpPower)",
   Range = {50, 400},
   Increment = 5,
   Suffix = " Power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
       currentJumpPower = Value
       local char = LocalPlayer.Character
       if char and char:FindFirstChild("Humanoid") then
           char.Humanoid.UseJumpPower = true
           char.Humanoid.JumpPower = Value
       end
   end,
})

SpeedTab:CreateToggle({
   Name = "ล็อคค่าความเร็วตลอดเวลา",
   CurrentValue = false,
   Flag = "LoopSpeedToggle",
   Callback = function(Value)
       if Value then
           if loopSpeedConnection then loopSpeedConnection:Disconnect() end
           loopSpeedConnection = RunService.Stepped:Connect(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("Humanoid") then
                   char.Humanoid.WalkSpeed = currentWalkSpeed
                   char.Humanoid.UseJumpPower = true
                   char.Humanoid.JumpPower = currentJumpPower
               end
           end)
       else
           if loopSpeedConnection then
               loopSpeedConnection:Disconnect()
               loopSpeedConnection = nil
           end
       end
   end,
})

SpeedTab:CreateButton({
   Name = "คืนค่าปกติทั้งหมด",
   Callback = function()
       currentWalkSpeed = 16
       currentJumpPower = 50
       local char = LocalPlayer.Character
       if char and char:FindFirstChild("Humanoid") then
           char.Humanoid.WalkSpeed = 16
           char.Humanoid.JumpPower = 50
       end
       Rayfield:Notify({Title = "รีเซ็ตสำเร็จ", Content = "คืนค่าทั้งหมดเป็นปกติ", Duration = 2})
   end,
})

----------------------------------------------------
-- 3. แท็บช่วยเหลือ + จมดิน + คีย์ลัด B
----------------------------------------------------
local UtilityTab = Window:CreateTab("ระบบช่วยเหลือ", 4483362458)

UtilityTab:CreateToggle({
   Name = "เปิดใช้งาน Anti-AFK",
   CurrentValue = false,
   Flag = "AntiAFKToggle",
   Callback = function(Value)
       if Value then
           if antiAfkConnection then antiAfkConnection:Disconnect() end
           antiAfkConnection = LocalPlayer.Idled:Connect(function()
               VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
               task.wait(1)
               VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
           end)
           Rayfield:Notify({Title = "Anti-AFK", Content = "เปิดใช้งานแล้ว", Duration = 3})
       else
           if antiAfkConnection then
               antiAfkConnection:Disconnect()
               antiAfkConnection = nil
           end
           Rayfield:Notify({Title = "Anti-AFK", Content = "ปิดใช้งานแล้ว", Duration = 3})
       end
   end,
})

-- จมดิน — ไม่ร่วงตาย + กลับขึ้นพื้นอัตโนมัติ
local function SetUndergroundState(Value)
    if Value == isHiddenActive then return end
    local char = LocalPlayer.Character
    if not char then return end

    if Value then
        isHiddenActive = true
        targetDepthOffset = Rayfield.Flags.HideDepth or 3
        originalTransparency = {}

        for _, Part in ipairs(char:GetDescendants()) do
            if Part:IsA("BasePart") then
                originalTransparency[Part] = {Transparency = Part.Transparency, CanCollide = Part.CanCollide}
                Part.Transparency = 1
                Part.CanCollide = false
            end
        end

        if hideLoop then hideLoop:Disconnect() end
        local startOffset = 0
        hideLoop = RunService.Stepped:Connect(function()
            if not isHiddenActive then return end
            local c = LocalPlayer.Character
            if not c then return end
            local root = c:FindFirstChild("HumanoidRootPart")
            if not root then return end

            if startOffset < targetDepthOffset then
                startOffset = math.min(startOffset + 0.5, targetDepthOffset)
                root.CFrame = root.CFrame * CFrame.new(0, -0.5, 0)
            end
        end)

        Rayfield:Notify({Title = "✅ เปิดซ่อนตัว", Content = "จมดินทำงานแล้ว", Duration = 2.5})
    else
        isHiddenActive = false
        if hideLoop then hideLoop:Disconnect() hideLoop = nil end

        -- กลับขึ้นพื้นอัตโนมัติ
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local depth = targetDepthOffset > 0 and targetDepthOffset or (Rayfield.Flags.HideDepth or 3)
            root.CFrame = root.CFrame * CFrame.new(0, depth, 0)
        end
        targetDepthOffset = 0

        for Part, State in pairs(originalTransparency) do
            if Part and Part:IsA("BasePart") then
                Part.Transparency = State.Transparency
                Part.CanCollide = State.CanCollide
            end
        end
        table.clear(originalTransparency)

        Rayfield:Notify({Title = "❌ ปิดซ่อนตัว", Content = "กลับขึ้นพื้นเรียบร้อย", Duration = 2.5})
    end
end

local UndergroundToggle = UtilityTab:CreateToggle({
   Name = "จมดิน+โปร่งใส (ฮิตบล็อกไม่หาย)",
   CurrentValue = false,
   Flag = "HideUndergroundToggle",
   Callback = SetUndergroundState,
})

UtilityTab:CreateKeybind({
   Name = "ปุ่มเปิด-ปิด จมดิน",
   CurrentKeybind = "B",
   HoldToInteract = false,
   Flag = "HideToggleKeybind",
   Callback = function()
       UndergroundToggle:Set(not isHiddenActive)
   end,
})

UtilityTab:CreateSlider({
   Name = "ระดับความลึกจมดิน",
   Range = {1, 15},
   Increment = 1,
   Suffix = " หน่วย",
   CurrentValue = 3,
   Flag = "HideDepth",
})

----------------------------------------------------
-- 4. แท็บ ESP แสดงผู้เล่น
----------------------------------------------------
local ESPTab = Window:CreateTab("ESP แสดงผู้เล่น", 4483362458)

local function CreateESPForPlayer(Player)
    if not Drawing then return end
    if espObjects[Player] then return end

    local ESP = {}
    ESP.Box = Drawing.new("Square")
    ESP.Box.Visible = false
    ESP.Box.Thickness = 2
    ESP.Box.Filled = false

    ESP.Name = Drawing.new("Text")
    ESP.Name.Visible = false
    ESP.Name.Center = true
    ESP.Name.Outline = true
    ESP.Name.Font = 2
    ESP.Name.Size = 13

    ESP.Distance = Drawing.new("Text")
    ESP.Distance.Visible = false
    ESP.Distance.Center = true
    ESP.Distance.Outline = true
    ESP.Distance.Font = 2
    ESP.Distance.Size = 11

    espObjects[Player] = ESP
end

local function RemoveESPForPlayer(Player)
    local ESP = espObjects[Player]
    if ESP then
        if ESP.Box then ESP.Box:Remove() end
        if ESP.Name then ESP.Name:Remove() end
        if ESP.Distance then ESP.Distance:Remove() end
        espObjects[Player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESPForPlayer)

local function UpdateESP()
    local ShowName = Rayfield.Flags.ESP_ShowName ~= false
    local ShowDist = Rayfield.Flags.ESP_ShowDistance ~= false
    local ShowBox = Rayfield.Flags.ESP_ShowBox ~= false
    local MaxDist = Rayfield.Flags.ESP_MaxDistance or 500

    for Player, ESP in pairs(espObjects) do
        if Player == LocalPlayer then goto continue end
        local Char = Player.Character
        if not Char then goto continue end
        local HRP = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChild("Humanoid")

        if not HRP or not Hum or Hum.Health <= 0 then
            ESP.Box.Visible = false
            ESP.Name.Visible = false
            ESP.Distance.Visible = false
            goto continue
        end

        local Pos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
        local Dist = (Camera.CFrame.Position - HRP.Position).Magnitude

        if not OnScreen or Dist > MaxDist then
            ESP.Box.Visible = false
            ESP.Name.Visible = false
            ESP.Distance.Visible = false
            goto continue
        end

        local BoxSize = math.floor(1800 / Pos.Z)
        local Color = Color3.fromRGB(255, 0, 0)

        ESP.Box.Visible = ShowBox
        if ShowBox then
            ESP.Box.Color = Color
            ESP.Box.Position = Vector2.new(Pos.X - BoxSize/2, Pos.Y - BoxSize/2)
            ESP.Box.Size = Vector2.new(BoxSize, BoxSize * 1.8)
        end

        ESP.Name.Visible = ShowName
        if ShowName then
            ESP.Name.Color = Color
            ESP.Name.Position = Vector2.new(Pos.X, Pos.Y - BoxSize/2 - 16)
            ESP.Name.Text = Player.Name
        end

        ESP.Distance.Visible = ShowDist
        if ShowDist then
            ESP.Distance.Color = Color3.fromRGB(220, 220, 220)
            ESP.Distance.Position = Vector2.new(Pos.X, Pos.Y + BoxSize/2 + 4)
            ESP.Distance.Text = math.floor(Dist).." studs"
        end

        ::continue::
    end
end

ESPTab:CreateToggle({
   Name = "เปิดใช้งาน ESP แสดงผู้เล่น",
   CurrentValue = false,
   Flag = "ESP_Enabled",
   Callback = function(Value)
       if Value then
           for _, P in ipairs(Players:GetPlayers()) do
               if P ~= LocalPlayer and not espObjects[P] then
                   CreateESPForPlayer(P)
               end
           end
           if not playerAddedConnection then
               playerAddedConnection = Players.PlayerAdded:Connect(function(P)
                   task.wait(0.5)
                   if Rayfield.Flags.ESP_Enabled then
                       CreateESPForPlayer(P)
                   end
               end)
           end
           if espLoop then espLoop:Disconnect() end
           espLoop = RunService.RenderStepped:Connect(UpdateESP)
           Rayfield:Notify({Title = "ESP", Content = "เปิดแสดงตำแหน่งแล้ว", Duration = 3})
       else
           if espLoop then espLoop:Disconnect() espLoop = nil end
           for _, E in pairs(espObjects) do
               E.Box.Visible = false
               E.Name.Visible = false
               E.Distance.Visible = false
           end
           Rayfield:Notify({Title = "ESP", Content = "ปิดระบบ ESP แล้ว", Duration = 3})
       end
   end,
})

ESPTab:CreateToggle({Name = "แสดงกล่องรอบตัว", CurrentValue = true, Flag = "ESP_ShowBox"})
ESPTab:CreateToggle({Name = "แสดงชื่อผู้เล่น", CurrentValue = true, Flag = "ESP_ShowName"})
ESPTab:CreateToggle({Name = "แสดงระยะห่าง", CurrentValue = true, Flag = "ESP_ShowDistance"})
ESPTab:CreateSlider({
   Name = "ระยะมองเห็นสูงสุด",
   Range = {50, 2000},
   Increment = 50,
   Suffix = " หน่วย",
   CurrentValue = 500,
   Flag = "ESP_MaxDistance",
})

----------------------------------------------------
-- 5. แท็บ Anti-Lag + FPS
----------------------------------------------------
local LagTab = Window:CreateTab("Anti-Lag / FPS", 4483362458)

local function OptimizePart(v)
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v:Destroy()
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    end
end

LagTab:CreateToggle({
   Name = "เปิด Anti-Lag (ลบเอฟเฟกต์+เงา)",
   CurrentValue = false,
   Flag = "AntiLagToggle",
   Callback = function(Value)
       isAntiLagActive = Value
       if Value then
           for _, v in ipairs(Workspace:GetDescendants()) do
               OptimizePart(v)
           end
           if Workspace:FindFirstChildOfClass("Terrain") then
               local Terrain = Workspace.Terrain
               Terrain.WaterWaveSize = 0
               Terrain.WaterWaveSpeed = 0
               Terrain.WaterReflectance = 0
           end
           if antiLagConnection then antiLagConnection:Disconnect() end
           antiLagConnection = Workspace.DescendantAdded:Connect(function(v)
               task.wait()
               if isAntiLagActive then OptimizePart(v) end
           end)
           Rayfield:Notify({Title = "Anti-Lag", Content = "เปิดโหมดประหยัดสเปกแล้ว", Duration = 2})
       else
           if antiLagConnection then antiLagConnection:Disconnect() end
           antiLagConnection = nil
           Rayfield:Notify({Title = "Anti-Lag", Content = "ปิดระบบแล้ว", Duration = 2})
       end
   end,
})

LagTab:CreateSlider({
   Name = "ปลดล็อก FPS",
   Range = {60, 240},
   Increment = 10,
   Suffix = " FPS",
   CurrentValue = 60,
   Flag = "FPSCapSlider",
   Callback = function(Value)
       if setfpscap then
           setfpscap(Value)
           Rayfield:Notify({Title = "FPS", Content = "ตั้งเป็น "..Value.." FPS", Duration = 2})
       end
   end,
})

LagTab:CreateToggle({
   Name = "แสดงตัวนับ FPS มุมขวาบน",
   CurrentValue = true,
   Flag = "FPSDisplayToggle",
   Callback = function(Value)
       ScreenGui.Enabled = Value
   end,
})

----------------------------------------------------
-- 6. แท็บ Fullbright สว่าง
----------------------------------------------------
local BrightTab = Window:CreateTab("ความสว่าง / แสง", 4483362458)

BrightTab:CreateToggle({
   Name = "เปิด Fullbright แมพสว่างตลอดเวลา",
   CurrentValue = false,
   Flag = "FullbrightToggle",
   Callback = function(Value)
       isFullbrightActive = Value
       if Value then
           if fullbrightLoop then fullbrightLoop:Disconnect() end
           fullbrightLoop = RunService.RenderStepped:Connect(function()
               if not isFullbrightActive then return end
               Lighting.ClockTime = 12
               Lighting.Brightness = 2
               Lighting.GlobalShadows = false
               Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
               Lighting.Ambient = Color3.fromRGB(140, 140, 140)
           end)
           Rayfield:Notify({Title = "Fullbright", Content = "แมพสว่างแล้ว", Duration = 2})
       else
           if fullbrightLoop then fullbrightLoop:Disconnect() end
           fullbrightLoop = nil
           Rayfield:Notify({Title = "Fullbright", Content = "กลับสู่แสงปกติ", Duration = 2})
       end
   end,
})

BrightTab:CreateButton({
   Name = "ลบหมอกและควันออกทั้งหมด",
   Callback = function()
       Lighting.FogEnd = 100000
       Lighting.FogStart = 0
       Lighting.FogColor = Color3.fromRGB(255, 255, 255)
       for _, v in ipairs(Lighting:GetChildren()) do
           if v:IsA("Atmosphere") or v:IsA("PostEffect") or v:IsA("Clouds") then
               v:Destroy()
           end
       end
       Rayfield:Notify({Title = "Clear Fog", Content = "ลบหมอกเรียบร้อย", Duration = 2})
   end,
})

-- โหลดค่าที่บันทึกไว้
Rayfield:LoadConfiguration()
