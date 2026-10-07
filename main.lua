-- ==================================================
-- Anti-Lag & Fullbright Hub (PC & Mobile Ready ✅)
-- ==================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

----------------------------------------------------
-- 0. ฟังก์ชันสลับการแสดงผลหน้าต่าง UI
----------------------------------------------------
local function ToggleRayfieldUI()
    local rayfieldGui = (gethui and gethui():FindFirstChild("Rayfield")) or CoreGui:FindFirstChild("Rayfield")
    if rayfieldGui then
        rayfieldGui.Enabled = not rayfieldGui.Enabled
    end
end

----------------------------------------------------
-- 1. ปุ่มลอยสำหรับมือถือ (Floating Button - ลากย้ายตำแหน่งได้)
----------------------------------------------------
local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "MobileToggleGui"
MobileGui.ResetOnSpawn = false

if gethui then
    MobileGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(MobileGui)
    MobileGui.Parent = CoreGui
else
    MobileGui.Parent = CoreGui
end

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Parent = MobileGui
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 15, 0.35, 0) -- วางไว้ฝั่งซ้ายของหน้าจอ
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 22
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
ToggleBtn.Active = true
ToggleBtn.Draggable = true -- ให้ผู้เล่นใช้นิ้วลากปุ่มไปวางตำแหน่งอื่นบนมือถือได้

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 24) -- ทำปุ่มทรงกลม
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Thickness = 2
BtnStroke.Color = Color3.fromRGB(0, 255, 127)
BtnStroke.Parent = ToggleBtn

-- กดแตะปุ่มเพื่อเปิด/ปิดเมนู
ToggleBtn.MouseButton1Click:Connect(ToggleRayfieldUI)

----------------------------------------------------
-- 2. ระบบเปิด-ปิด ด้วยปุ่ม Left Control (สำหรับ PC)
----------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        ToggleRayfieldUI()
    end
end)

----------------------------------------------------
-- 3. ระบบแสดงผล FPS มุมขวาบน (ทำงานตลอดเวลา)
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RealtimeFPSDisplay"
ScreenGui.ResetOnSpawn = false

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
Frame.Size = UDim2.new(0, 110, 0, 32)
Frame.Position = UDim2.new(1, -15, 0, 15)
Frame.AnchorPoint = Vector2.new(1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.25
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Parent = Frame

local FPSText = Instance.new("TextLabel")
FPSText.Parent = Frame
FPSText.Size = UDim2.new(1, 0, 1, 0)
FPSText.BackgroundTransparency = 1
FPSText.Font = Enum.Font.SourceSansBold
FPSText.TextSize = 16
FPSText.TextColor3 = Color3.fromRGB(0, 255, 127)
FPSText.Text = "⚡ FPS: --"

local lastUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function(deltaTime)
    frameCount = frameCount + 1
    local now = tick()
    
    if now - lastUpdate >= 0.25 then
        local fps = math.floor(frameCount / (now - lastUpdate))
        FPSText.Text = "⚡ FPS: " .. tostring(fps)
        
        if fps >= 50 then
            FPSText.TextColor3 = Color3.fromRGB(0, 255, 127)
        elseif fps >= 30 then
            FPSText.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            FPSText.TextColor3 = Color3.fromRGB(255, 60, 60)
        end
        
        frameCount = 0
        lastUpdate = now
    end
end)

----------------------------------------------------
-- 4. เมนูหลัก (Rayfield UI Window)
----------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "⚡ Anti-Lag & Lighting Hub",
   LoadingTitle = "กำลังโหลดเมนู...",
   LoadingSubtitle = "กดปุ่ม ⚡ บนจอ หรือ Left Ctrl เพื่อเปิด-ปิด",
   ConfigurationSaving = { Enabled = false }
})

----------------------------------------------------
-- 5. แท็บ Anti-Lag / เพิ่ม FPS
----------------------------------------------------
local LagTab = Window:CreateTab("Anti-Lag (FPS)", 4483362458)

local isAntiLagActive = false
local antiLagConnection = nil

local function OptimizePart(v)
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v:Destroy()
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        v.Enabled = false
    end
end

LagTab:CreateToggle({
   Name = "เปิดใช้งาน Anti-Lag (เปลี่ยนพื้นผิว + ลบเอฟเฟกต์)",
   CurrentValue = false,
   Flag = "AntiLagToggle",
   Callback = function(Value)
       isAntiLagActive = Value
       if Value then
           for _, v in ipairs(Workspace:GetDescendants()) do
               OptimizePart(v)
           end

           if Workspace:FindFirstChildOfClass("Terrain") then
               local terrain = Workspace.Terrain
               terrain.WaterWaveSize = 0
               terrain.WaterWaveSpeed = 0
               terrain.WaterReflectance = 0
               terrain.WaterTransparency = 0
           end

           if antiLagConnection then antiLagConnection:Disconnect() end
           antiLagConnection = Workspace.DescendantAdded:Connect(function(v)
               if isAntiLagActive then
                   task.wait()
                   OptimizePart(v)
               end
           end)

           Rayfield:Notify({Title = "Anti-Lag", Content = "เปิดใช้งานโหมดประหยัดสเปกแล้ว", Duration = 2})
       else
           if antiLagConnection then
               antiLagConnection:Disconnect()
               antiLagConnection = nil
           end
           Rayfield:Notify({Title = "Anti-Lag", Content = "ปิดใช้งานระบบ Auto Anti-Lag แล้ว", Duration = 2})
       end
   end,
})

LagTab:CreateSlider({
   Name = "ปลดล็อก FPS (FPS Cap)",
   Range = {60, 240},
   Increment = 10,
   Suffix = " FPS",
   CurrentValue = 60,
   Flag = "FPSCapSlider",
   Callback = function(Value)
       if setfpscap then
           setfpscap(Value)
           Rayfield:Notify({Title = "FPS Cap", Content = "ตั้งค่า FPS เป็น " .. Value, Duration = 2})
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

LagTab:CreateToggle({
   Name = "แสดงปุ่มลอย ⚡ เปิด-ปิด เมนู (สำหรับมือถือ)",
   CurrentValue = true,
   Flag = "MobileBtnToggle",
   Callback = function(Value)
       MobileGui.Enabled = Value
   end,
})

----------------------------------------------------
-- 6. แท็บแมพสว่าง (Fullbright)
----------------------------------------------------
local BrightTab = Window:CreateTab("ความสว่าง (Fullbright)", 4483362458)

local isFullbrightActive = false
local fullbrightLoop = nil

BrightTab:CreateToggle({
   Name = "เปิดใช้งาน แมพสว่าง + ท้องฟ้าเที่ยงวัน",
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
               Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
               Lighting.Ambient = Color3.fromRGB(128, 128, 128)
           end)
           Rayfield:Notify({Title = "Fullbright", Content = "เปิดใช้งานแมพสว่างแล้ว", Duration = 2})
       else
           if fullbrightLoop then
               fullbrightLoop:Disconnect()
               fullbrightLoop = nil
           end
           Rayfield:Notify({Title = "Fullbright", Content = "ปิดใช้งานแมพสว่างแล้ว", Duration = 2})
       end
   end,
})

BrightTab:CreateButton({
   Name = "ลบหมอกมืดออก (Clear Fog)",
   Callback = function()
       Lighting.FogEnd = 9e9
       Lighting.FogStart = 0
       for _, v in ipairs(Lighting:GetChildren()) do
           if v:IsA("Atmosphere") or v:IsA("Clouds") or v:IsA("PostEffect") then
               v:Destroy()
           end
       end
       Rayfield:Notify({Title = "Clear Fog", Content = "ลบหมอกมืดและก้อนเมฆออกเรียบร้อย", Duration = 2})
   end,
})
