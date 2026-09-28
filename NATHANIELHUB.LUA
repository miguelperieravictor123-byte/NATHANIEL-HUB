--=====================================================================
--   SACRIFICE HUB  |  Painel Arrastável
--   Aimbot • ESP • Teleport • Voar • Noclip
--=====================================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LP = Players.LocalPlayer

--// ---------- PARENT ----------
local parent
if gethui then
    parent = gethui()
else
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    parent = (ok and cg) or LP:WaitForChild("PlayerGui")
end

local function safeParent(o)
    local ok = pcall(function() o.Parent = parent end)
    if not ok then o.Parent = LP:WaitForChild("PlayerGui") end
end

--// ---------- CORES ----------
local ACCENT = Color3.fromRGB(255, 0, 60)
local BG     = Color3.fromRGB(9, 9, 11)
local BG2    = Color3.fromRGB(19, 19, 23)
local BG3    = Color3.fromRGB(33, 33, 39)
local TXT    = Color3.fromRGB(235, 235, 240)
local SUB    = Color3.fromRGB(125, 125, 140)

--=====================================================================
--  ROOT GUI
--=====================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "SacrificeHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
safeParent(gui)

local espGui = Instance.new("ScreenGui")
espGui.Name = "SacrificeESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 5
safeParent(espGui)

--// ---------- DRAG ----------
local function makeDraggable(frame, handle, onClick)
    local dragging, dragStart, startPos, moved = false, nil, nil, false

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then moved = true end
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    if onClick then
        handle.MouseButton1Click:Connect(function()
            if not moved then onClick() end
        end)
    end
end

--=====================================================================
--  BOTÃO CIRCULAR (abre / fecha)
--=====================================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.fromOffset(58, 58)
toggleBtn.Position = UDim2.new(0, 60, 0.5, -29)
toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
toggleBtn.Text = "S"
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = ACCENT
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local tglStroke = Instance.new("UIStroke", toggleBtn)
tglStroke.Color = ACCENT
tglStroke.Thickness = 2
tglStroke.Transparency = 0.15

--=====================================================================
--  PAINEL
--=====================================================================
local panel = Instance.new("CanvasGroup")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(360, 460)
panel.Position = UDim2.new(0.5, -180, 0.5, -230)
panel.BackgroundColor3 = BG
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.GroupTransparency = 1
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = Color3.fromRGB(45, 45, 55)
panelStroke.Thickness = 1.2

local panelScale = Instance.new("UIScale", panel)
panelScale.Scale = 0.9

--// ---------- HEADER ----------
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundTransparency = 1
header.Parent = panel

local logo = Instance.new("TextLabel")
logo.RichText = true
logo.Text = '<font color="rgb(255,0,60)">SACRIFICE</font> HUB'
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 15
logo.TextColor3 = Color3.fromRGB(255, 255, 255)
logo.BackgroundTransparency = 1
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.Size = UDim2.new(1, -32, 1, 0)
logo.Position = UDim2.new(0, 16, 0, 0)
logo.Parent = header

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, -32, 0, 2)
accentLine.Position = UDim2.new(0, 16, 1, -2)
accentLine.BackgroundColor3 = ACCENT
accentLine.BorderSizePixel = 0
accentLine.Parent = header

--// ---------- SIDEBAR ----------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 96, 1, -62)
sidebar.Position = UDim2.new(0, 12, 0, 54)
sidebar.BackgroundTransparency = 1
sidebar.Parent = panel

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 5)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sidebar

--// ---------- CONTENT ----------
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -132, 1, -66)
content.Position = UDim2.new(0, 120, 0, 54)
content.BackgroundTransparency = 1
content.Parent = panel

--=====================================================================
--  SISTEMA DE ABAS
--=====================================================================
local tabButtons = {}
local tabPages   = {}

local function selectTab(i)
    for idx, page in ipairs(tabPages) do
        page.Visible = (idx == i)
    end
    for idx, btn in ipairs(tabButtons) do
        local on = (idx == i)
        TweenService:Create(btn, TweenInfo.new(0.18), {
            BackgroundColor3 = on and ACCENT or BG2
        }):Play()
        local lbl = btn:FindFirstChildOfClass("TextLabel")
        if lbl then
            TweenService:Create(lbl, TweenInfo.new(0.18), {
                TextColor3 = on and Color3.fromRGB(255,255,255) or SUB
            }):Play()
        end
    end
end

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = BG2
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10.5
    lbl.TextColor3 = SUB
    lbl.Parent = btn

    table.insert(tabButtons, btn)
    local index = #tabButtons

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 8)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = page

    table.insert(tabPages, page)

    btn.MouseButton1Click:Connect(function() selectTab(index) end)
    return page
end

--=====================================================================
--  COMPONENTES
--=====================================================================
local function addToggle(page, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = BG2
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Text = text
    lbl.Parent = row

    local state = default

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.fromOffset(42, 20)
    switch.Position = UDim2.new(1, -54, 0.5, -10)
    switch.BackgroundColor3 = state and ACCENT or BG3
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = row
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    switch.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switch, TweenInfo.new(0.18), {
            BackgroundColor3 = state and ACCENT or BG3
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        callback(state)
    end)

    return switch
end

local function addSlider(page, text, minV, maxV, default, decimals, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = BG2
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1, -24, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 6)
    lbl.Text = text
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextColor3 = ACCENT
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Size = UDim2.new(1, -24, 0, 18)
    valLbl.Position = UDim2.new(0, 12, 0, 6)
    valLbl.Parent = row

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 1, -16)
    bar.BackgroundColor3 = BG3
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Parent = row
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(11, 11)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local value = default

    local function setValue(v, fire)
        v = math.clamp(v, minV, maxV)
        value = v
        local alpha = (v - minV) / (maxV - minV)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        if decimals <= 0 then
            valLbl.Text = tostring(math.floor(v + 0.5))
        else
            valLbl.Text = string.format("%." .. decimals .. "f", v)
        end
        if fire then callback(v) end
    end

    local dragging = false
    local function updateFromX(x)
        local rel = (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        setValue(minV + (maxV - minV) * math.clamp(rel, 0, 1), true)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    setValue(default, true)
    return bar
end

local function addOptions(page, text, options, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = BG2
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(0.45, -12, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Text = text
    lbl.Parent = row

    local idx = 1
    for i, o in ipairs(options) do
        if o == default then idx = i end
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 118, 0, 23)
    btn.Position = UDim2.new(1, -130, 0.5, -11.5)
    btn.BackgroundColor3 = BG3
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = ACCENT
    btn.Text = options[idx]
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        btn.Text = options[idx]
        callback(options[idx])
    end)
end

local function addButton(page, text, bg, txtColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = bg
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = txtColor
    btn.Text = text
    btn.Parent = page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(60,60,70)}):Play()
        task.delay(0.09, function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = bg}):Play()
        end)
        callback()
    end)
    return btn
end

local function addColorRow(page, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 54)
    row.BackgroundColor3 = BG2
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1, -24, 0, 16)
    lbl.Position = UDim2.new(0, 12, 0, 5)
    lbl.Text = "CORES ESP"
    lbl.Parent = row

    local colors = {
        Color3.fromRGB(255, 0, 60),
        Color3.fromRGB(0, 255, 140),
        Color3.fromRGB(0, 160, 255),
        Color3.fromRGB(255, 220, 0),
        Color3.fromRGB(180, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 120, 0),
    }

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 24)
    holder.Position = UDim2.new(0, 10, 0, 24)
    holder.BackgroundTransparency = 1
    holder.Parent = row

    local hl = Instance.new("UIListLayout", holder)
    hl.FillDirection = Enum.FillDirection.Horizontal
    hl.Padding = UDim.new(0, 6)
    hl.SortOrder = Enum.SortOrder.LayoutOrder

    for i, c in ipairs(colors) do
        local dot = Instance.new("TextButton")
        dot.Size = UDim2.fromOffset(22, 22)
        dot.BackgroundColor3 = c
        dot.Text = ""
        dot.AutoButtonColor = false
        dot.LayoutOrder = i
        dot.Parent = holder
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        dot.MouseButton1Click:Connect(function()
            callback(c)
        end)
    end
end

--=====================================================================
--  ESTADOS
--=====================================================================
local AIM = {
    enabled = false,
    fov     = 140,
    part    = "Head",
    smooth  = 0.35,
}

local ESP = {
    enabled  = false,
    aura     = false,
    name     = false,
    distance = false,
    skeleton = false,
    color    = ACCENT,
}

local FLY = {
    enabled  = false,
    speed    = 60,
    vertical = true,
}

local NOCLIP = {
    enabled = false,
}

--=====================================================================
--  FOV CIRCLE (declarado antes para ser usado nos controles)
--=====================================================================
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(AIM.fov * 2, AIM.fov * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = espGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = ACCENT
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.35

--=====================================================================
--  ABAS + CONTROLES
--=====================================================================
local aimPage  = createTab("AIMBOT")
local espPage  = createTab("ESP")
local tpPage   = createTab("TELEPORT")
local flyPage  = createTab("VOAR")
local clipPage = createTab("NOCLIP")

--// ---------- AIMBOT ----------
addToggle(aimPage, "ATIVAR AIMBOT", false, function(v)
    AIM.enabled = v
    fovCircle.Visible = v
end)

addSlider(aimPage, "REGULAR FOV", 20, 500, 140, 0, function(v)
    AIM.fov = v
    fovCircle.Size = UDim2.fromOffset(v * 2, v * 2)
end)

addOptions(aimPage, "ALVO", {"CABEÇA", "PESCOÇO", "PEITO"}, "CABEÇA", function(opt)
    if opt == "CABEÇA" then
        AIM.part = "Head"
    elseif opt == "PESCOÇO" then
        AIM.part = "Neck"
    else
        AIM.part = "Chest"
    end
end)

addSlider(aimPage, "SUAVIDADE", 0.05, 1, 0.35, 2, function(v)
    AIM.smooth = v
end)

--// ---------- ESP ----------
addToggle(espPage, "ATIVAR ESP", false, function(v) ESP.enabled = v end)
addToggle(espPage, "ESP AURA", false, function(v) ESP.aura = v end)
addToggle(espPage, "ESP NOME", false, function(v) ESP.name = v end)
addToggle(espPage, "ESP DISTÂNCIA", false, function(v) ESP.distance = v end)
addToggle(espPage, "ESP ESQUELETO", false, function(v) ESP.skeleton = v end)
addColorRow(espPage, function(c) ESP.color = c end)

--// ---------- TELEPORT ----------
local savedCFrame = nil
local autoReturn = false

addButton(tpPage, "SALVAR POSIÇÃO (SPAWN)", BG2, ACCENT, function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        savedCFrame = root.CFrame
    end
end)

addButton(tpPage, "IR PARA POSIÇÃO SALVA", ACCENT, Color3.fromRGB(255,255,255), function()
    if not savedCFrame then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = savedCFrame
    end
end)

addToggle(tpPage, "AUTO RETORNO", false, function(v)
    autoReturn = v
    if v and savedCFrame then
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = savedCFrame end
    end
end)

addButton(tpPage, "LIMPAR POSIÇÃO SALVA", BG2, Color3.fromRGB(255, 90, 90), function()
    savedCFrame = nil
end)

--// ---------- VOAR ----------
local function stopFly()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if root then
        local bv = root:FindFirstChild("SAC_FlyVel");  if bv then bv:Destroy() end
        local bg = root:FindFirstChild("SAC_FlyGyro"); if bg then bg:Destroy() end
    end
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not (root and hum) then return end

    local bodyVel = root:FindFirstChild("SAC_FlyVel") or Instance.new("BodyVelocity")
    bodyVel.Name = "SAC_FlyVel"
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = root

    local bodyGyro = root:FindFirstChild("SAC_FlyGyro") or Instance.new("BodyGyro")
    bodyGyro.Name = "SAC_FlyGyro"
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 3000
    bodyGyro.D = 50
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    hum.PlatformStand = true
end

addToggle(flyPage, "ATIVAR VOAR", false, function(v)
    FLY.enabled = v
    if v then
        startFly()
    else
        stopFly()
    end
end)

addSlider(flyPage, "VELOCIDADE DO VOO", 10, 300, 60, 0, function(v)
    FLY.speed = v
end)

addToggle(flyPage, "SUBIR / DESCER (Space / Shift)", true, function(v)
    FLY.vertical = v
end)

addButton(flyPage, "RESETAR VOO", BG2, ACCENT, function()
    FLY.enabled = false
    stopFly()
end)

--// ---------- NOCLIP ----------
addToggle(clipPage, "ATIVAR NOCLIP (ATRAVESSAR PAREDE)", false, function(v)
    NOCLIP.enabled = v
    if not v then
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
        end
    end
end)

addButton(clipPage, "DESLIGAR NOCLIP", BG2, Color3.fromRGB(255, 90, 90), function()
    NOCLIP.enabled = false
    local char = LP.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
    end
end)

--=====================================================================
--  ANIMAÇÃO ABRIR / FECHAR
--=====================================================================
local isOpen = false

local function togglePanel()
    isOpen = not isOpen

    if isOpen then
        panel.Visible = true
        panelScale.Scale = 0.9
        panel.GroupTransparency = 1

        TweenService:Create(panelScale,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Scale = 1}):Play()

        TweenService:Create(panel,
            TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {GroupTransparency = 0}):Play()

        TweenService:Create(tglStroke, TweenInfo.new(0.25), {
            Transparency = 0,
            Color = ACCENT
        }):Play()
    else
        TweenService:Create(panelScale,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Scale = 0.9}):Play()

        local t = TweenService:Create(panel,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {GroupTransparency = 1})
        t.Completed:Connect(function()
            if not isOpen then panel.Visible = false end
        end)
        t:Play()

        TweenService:Create(tglStroke, TweenInfo.new(0.25), {Transparency = 0.6}):Play()
    end
end

makeDraggable(panel, header)
makeDraggable(toggleBtn, toggleBtn, togglePanel)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        togglePanel()
    end
end)

selectTab(1)

--=====================================================================
--  AIMBOT — LÓGICA
--=====================================================================
local PART_MAP = {
    Head  = {"Head"},
    Neck  = {"Neck", "Head"},
    Chest = {"UpperTorso", "Torso", "Head"},
}

local function resolvePart(char, key)
    for _, n in ipairs(PART_MAP[key] or {"Head"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getTarget(cam)
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, closestDist = nil, AIM.fov

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = resolvePart(char, AIM.part)
                    if part then
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen and sp.Z > 0 then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d <= closestDist then
                                closest, closestDist = part, d
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

--=====================================================================
--  ESP — LÓGICA
--=====================================================================
local espData = {}

local R15_BONES = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local R6_BONES = {
    {"Head","Torso"},
    {"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function ensureLines(plr, count)
    local d = espData[plr]
    if not d then d = {lines = {}}; espData[plr] = d end
    if not d.lines then d.lines = {} end

    while #d.lines < count do
        local f = Instance.new("Frame")
        f.BackgroundColor3 = ESP.color
        f.BorderSizePixel = 0
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Size = UDim2.fromOffset(0, 1)
        f.Visible = false
        f.ZIndex = 2
        f.Parent = espGui
        table.insert(d.lines, f)
    end
    return d.lines
end

local function clearESP(plr)
    local d = espData[plr]
    if not d then return end
    if d.hl and d.hl.Parent then d.hl:Destroy() end
    if d.tag and d.tag.Parent then d.tag:Destroy() end
    d.hl, d.tag = nil, nil
    for _, l in ipairs(d.lines or {}) do
        l.Visible = false
    end
end

local function updateESP(plr, char, cam)
    local d = espData[plr]
    if not d then d = {lines = {}}; espData[plr] = d end

    if d.char ~= char then
        d.char = char
        d.hl, d.tag = nil, nil
    end

    --// AURA
    if ESP.aura then
        if not (d.hl and d.hl.Parent) then
            local hl = Instance.new("Highlight")
            hl.Name = "SAC_Highlight"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
            d.hl = hl
        end
        d.hl.FillColor = ESP.color
        d.hl.OutlineColor = ESP.color
        d.hl.FillTransparency = 0.55
        d.hl.OutlineTransparency = 0
    elseif d.hl then
        d.hl:Destroy()
        d.hl = nil
    end

    --// NOME / DISTÂNCIA
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")

    if (ESP.name or ESP.distance) and head and root then
        if not (d.tag and d.tag.Parent) then
            local tag = Instance.new("BillboardGui")
            tag.Name = "SAC_Tag"
            tag.Size = UDim2.fromOffset(230, 40)
            tag.StudsOffsetWorldSpace = Vector3.new(0, 2.9, 0)
            tag.AlwaysOnTop = true
            tag.MaxDistance = 600
            tag.Parent = head

            local n = Instance.new("TextLabel")
            n.Name = "NameLbl"
            n.BackgroundTransparency = 1
            n.Size = UDim2.new(1, 0, 0, 18)
            n.Font = Enum.Font.GothamBold
            n.TextSize = 13
            n.TextStrokeTransparency = 0
            n.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            n.Text = plr.Name
            n.Parent = tag

            local ds = Instance.new("TextLabel")
            ds.Name = "DistLbl"
            ds.BackgroundTransparency = 1
            ds.Size = UDim2.new(1, 0, 0, 16)
            ds.Position = UDim2.new(0, 0, 0, 18)
            ds.Font = Enum.Font.GothamBold
            ds.TextSize = 11
            ds.TextStrokeTransparency = 0
            ds.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            ds.Text = ""
            ds.Parent = tag

            d.tag = tag
        end

        local n = d.tag:FindFirstChild("NameLbl")
        local ds = d.tag:FindFirstChild("DistLbl")

        if n then
            n.Visible = ESP.name
            n.TextColor3 = ESP.color
            n.Text = plr.Name
        end
        if ds then
            ds.Visible = ESP.distance
            ds.TextColor3 = ESP.color
            ds.Text = string.format("%d m", math.floor((root.Position - cam.CFrame.Position).Magnitude))
        end
    elseif d.tag then
        d.tag:Destroy()
        d.tag = nil
    end

    --// ESQUELETO
    if ESP.skeleton then
        local bones = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
        local lines = ensureLines(plr, #bones)
        local idx = 0

        for _, bone in ipairs(bones) do
            local a = char:FindFirstChild(bone[1])
            local b = char:FindFirstChild(bone[2])

            if a and b then
                idx = idx + 1
                local line = lines[idx]
                local pa, onA = cam:WorldToViewportPoint(a.Position)
                local pb, onB = cam:WorldToViewportPoint(b.Position)

                if onA and onB and pa.Z > 0 and pb.Z > 0 then
                    local va = Vector2.new(pa.X, pa.Y)
                    local vb = Vector2.new(pb.X, pb.Y)
                    local mid = (va + vb) / 2
                    local dist = (vb - va).Magnitude

                    line.Position = UDim2.fromOffset(mid.X, mid.Y)
                    line.Size = UDim2.fromOffset(dist, 1)
                    line.Rotation = math.deg(math.atan2(vb.Y - va.Y, vb.X - va.X))
                    line.BackgroundColor3 = ESP.color
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        end

        for i = idx + 1, #lines do
            lines[i].Visible = false
        end
    else
        for _, l in ipairs((espData[plr] and espData[plr].lines) or {}) do
            l.Visible = false
        end
    end
end

--=====================================================================
--  LIMPEZA
--=====================================================================
Players.PlayerRemoving:Connect(function(plr)
    local d = espData[plr]
    if d then
        for _, l in ipairs(d.lines or {}) do l:Destroy() end
        espData[plr] = nil
    end
end)

--// Respawn: religa o fly se morrer enquanto voava
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if FLY.enabled then startFly() end
end)

--=====================================================================
--  LOOP PRINCIPAL
--=====================================================================
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    --// AIMBOT
    if AIM.enabled then
        local target = getTarget(cam)
        if target then
            local goal = CFrame.new(cam.CFrame.Position, target.Position)
            local alpha = math.clamp(AIM.smooth, 0.05, 1)
            cam.CFrame = cam.CFrame:Lerp(goal, alpha)
        end
    end

    --// ESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local alive = char and hum and hum.Health > 0

            if ESP.enabled and alive then
                updateESP(plr, char, cam)
            else
                clearESP(plr)
            end
        end
    end

    --// AUTO RETORNO
    if autoReturn and savedCFrame then
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and (root.Position - savedCFrame.Position).Magnitude > 3 then
            root.CFrame = savedCFrame
        end
    end

    --// VOAR
    if FLY.enabled then
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum then
            local bv = root:FindFirstChild("SAC_FlyVel")
            local bg = root:FindFirstChild("SAC_FlyGyro")
            if bv and bg then
                local move = Vector3.zero

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end

                if FLY.vertical then
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        move += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                    or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        move -= Vector3.new(0, 1, 0)
                    end
                end

                if move.Magnitude > 0 then
                    move = move.Unit * FLY.speed
                end

                bv.Velocity = move
                bg.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
                hum.PlatformStand = true
            end
        end
    end

    --// NOCLIP
    if NOCLIP.enabled then
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end
end)

--=====================================================================
--  FIM — SACRIFICE HUB
--=====================================================================
