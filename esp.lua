-- Branded by zmods --

--[[ =========================================================
     zmods v2.1 — 2D Box ESP
     Sections:
       1. Services & State
       2. Root ScreenGui
       3. Launch Icon (zmods circle)
       4. Main Menu (Control Panel)
       5. Drag System (UserInputService)
       6. ESP Logic (camera-facing, nicknames, HSV slider)
       7. UI Interaction Wiring
     ========================================================= ]]

--[[ =========================================================
     SECTION 1 — SERVICES & STATE
     ========================================================= ]]

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Camera         = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ESP state
local espEnabled         = false
local espHue             = 0          -- 0 – 1 (red → full spectrum)
local espColor           = Color3.fromHSV(espHue, 1, 1)
local espBoxes           = {}
local heartbeatConnection = nil

-- Drag persistence
local iconLastPos  = UDim2.new(1, -80, 1, -80)   -- bottom-right default
local menuLastPos  = UDim2.new(1, -350, 1, -295)

local MENU_W, MENU_H = 280, 240
local ICON_SIZE      = 64

--[[ =========================================================
     SECTION 2 — ROOT SCREENGUI
     ========================================================= ]]

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "zmodsESP"
ScreenGui.ResetOnSpawn     = false
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset   = true
ScreenGui.Parent           = CoreGui

--[[ =========================================================
     SECTION 3 — LAUNCH ICON
     Draggable circle — clicking opens the menu
     ========================================================= ]]

local LaunchCircle = Instance.new("Frame")
LaunchCircle.Name                 = "LaunchCircle"
LaunchCircle.Size                 = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
LaunchCircle.Position             = iconLastPos
LaunchCircle.BackgroundColor3     = Color3.fromRGB(28, 28, 28)
LaunchCircle.BackgroundTransparency = 0.3
LaunchCircle.BorderSizePixel      = 0
LaunchCircle.ZIndex               = 10
LaunchCircle.Parent               = ScreenGui

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = LaunchCircle
end

local LaunchLabel = Instance.new("TextLabel")
LaunchLabel.Size               = UDim2.new(1, 0, 1, 0)
LaunchLabel.BackgroundTransparency = 1
LaunchLabel.Text               = "zmods"
LaunchLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
LaunchLabel.Font               = Enum.Font.GothamBold
LaunchLabel.TextSize           = 13
LaunchLabel.ZIndex             = 11
LaunchLabel.Parent             = LaunchCircle

-- Invisible hit-target on top of the circle
local LaunchBtn = Instance.new("TextButton")
LaunchBtn.Size               = UDim2.new(1, 0, 1, 0)
LaunchBtn.BackgroundTransparency = 1
LaunchBtn.Text               = ""
LaunchBtn.ZIndex             = 12
LaunchBtn.Parent             = LaunchCircle

--[[ =========================================================
     SECTION 4 — MAIN MENU
     FinTech deep-grey palette, no orange-gold
     ========================================================= ]]

local MainMenu = Instance.new("Frame")
MainMenu.Name                 = "MainMenu"
MainMenu.Size                 = UDim2.new(0, MENU_W, 0, MENU_H)
MainMenu.Position             = menuLastPos
MainMenu.BackgroundColor3     = Color3.fromRGB(20, 20, 20)
MainMenu.BackgroundTransparency = 0.12
MainMenu.BorderSizePixel      = 0
MainMenu.Visible              = false
MainMenu.ZIndex               = 20
MainMenu.Parent               = ScreenGui

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = MainMenu

    local s = Instance.new("UIStroke")
    s.Color     = Color3.fromRGB(70, 70, 70)
    s.Thickness = 1
    s.Parent    = MainMenu
end

-- ── Header ────────────────────────────────────────────────

local Header = Instance.new("Frame")
Header.Name                 = "Header"
Header.Size                 = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3     = Color3.fromRGB(38, 38, 38)
Header.BackgroundTransparency = 0.1
Header.BorderSizePixel      = 0
Header.ZIndex               = 21
Header.Parent               = MainMenu

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = Header

    -- Fill to square off the bottom corners of the header
    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(1, 0, 0, 12)
    fill.Position         = UDim2.new(0, 0, 1, -12)
    fill.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    fill.BackgroundTransparency = 0.1
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 21
    fill.Parent           = Header
end

-- Clickable title — closes menu, restores icon
local TitleBtn = Instance.new("TextButton")
TitleBtn.Name               = "TitleBtn"
TitleBtn.Size               = UDim2.new(1, -70, 1, 0)
TitleBtn.Position           = UDim2.new(0, 14, 0, 0)
TitleBtn.BackgroundTransparency = 1
TitleBtn.Text               = "zmods"
TitleBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
TitleBtn.Font               = Enum.Font.GothamBold
TitleBtn.TextSize           = 15
TitleBtn.TextXAlignment     = Enum.TextXAlignment.Left
TitleBtn.ZIndex             = 23
TitleBtn.Parent             = Header

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size               = UDim2.new(0, 26, 0, 26)
MinBtn.Position           = UDim2.new(1, -60, 0.5, -13)
MinBtn.BackgroundColor3   = Color3.fromRGB(55, 55, 55)
MinBtn.BorderSizePixel    = 0
MinBtn.Text               = "—"
MinBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
MinBtn.Font               = Enum.Font.GothamBold
MinBtn.TextSize           = 13
MinBtn.ZIndex             = 24
MinBtn.Parent             = Header

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = MinBtn
end

-- Close button (X) — full script kill
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size               = UDim2.new(0, 26, 0, 26)
CloseBtn.Position           = UDim2.new(1, -28, 0.5, -13)
CloseBtn.BackgroundColor3   = Color3.fromRGB(180, 40, 40)
CloseBtn.BorderSizePixel    = 0
CloseBtn.Text               = "✕"
CloseBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
CloseBtn.Font               = Enum.Font.GothamBold
CloseBtn.TextSize           = 13
CloseBtn.ZIndex             = 24
CloseBtn.Parent             = Header

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = CloseBtn
end

-- ── Body ──────────────────────────────────────────────────

local Body = Instance.new("Frame")
Body.Name               = "Body"
Body.Size               = UDim2.new(1, 0, 1, -42)
Body.Position           = UDim2.new(0, 0, 0, 42)
Body.BackgroundTransparency = 1
Body.ZIndex             = 21
Body.Parent             = MainMenu

do
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, 14)
    p.PaddingRight  = UDim.new(0, 14)
    p.PaddingTop    = UDim.new(0, 14)
    p.PaddingBottom = UDim.new(0, 14)
    p.Parent = Body

    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Vertical
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Padding       = UDim.new(0, 10)
    l.Parent        = Body
end

-- ── ESP Toggle Button ─────────────────────────────────────

local ESPBtn = Instance.new("TextButton")
ESPBtn.Name             = "ESPBtn"
ESPBtn.Size             = UDim2.new(1, 0, 0, 48)
ESPBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ESPBtn.BackgroundTransparency = 0.2
ESPBtn.BorderSizePixel  = 0
ESPBtn.Text             = "2D ESP (Wall)      OFF"
ESPBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
ESPBtn.Font             = Enum.Font.GothamBold
ESPBtn.TextSize         = 15
ESPBtn.LayoutOrder      = 1
ESPBtn.ZIndex           = 22
ESPBtn.Parent           = Body

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = ESPBtn
end

-- ── HSV Hue Slider ────────────────────────────────────────

local SliderContainer = Instance.new("Frame")
SliderContainer.Name               = "SliderContainer"
SliderContainer.Size               = UDim2.new(1, 0, 0, 36)
SliderContainer.BackgroundTransparency = 1
SliderContainer.LayoutOrder        = 2
SliderContainer.ZIndex             = 22
SliderContainer.Parent             = Body

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size               = UDim2.new(1, 0, 0, 14)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text               = "Color"
SliderLabel.TextColor3         = Color3.fromRGB(200, 200, 200)
SliderLabel.Font               = Enum.Font.GothamBold
SliderLabel.TextSize           = 12
SliderLabel.TextXAlignment     = Enum.TextXAlignment.Left
SliderLabel.ZIndex             = 22
SliderLabel.Parent             = SliderContainer

-- Hue gradient track
local SliderTrack = Instance.new("Frame")
SliderTrack.Name               = "SliderTrack"
SliderTrack.Size               = UDim2.new(1, 0, 0, 16)
SliderTrack.Position           = UDim2.new(0, 0, 0, 18)
SliderTrack.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
SliderTrack.BorderSizePixel    = 0
SliderTrack.ZIndex             = 22
SliderTrack.Parent             = SliderContainer

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = SliderTrack

    -- Rainbow gradient via UIGradient
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,  1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1, 1)),
    })
    grad.Parent = SliderTrack
end

-- Knob
local SliderKnob = Instance.new("Frame")
SliderKnob.Name               = "SliderKnob"
SliderKnob.Size               = UDim2.new(0, 16, 0, 16)
SliderKnob.Position           = UDim2.new(0, 0, 0, 0)
SliderKnob.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel    = 0
SliderKnob.ZIndex             = 24
SliderKnob.Parent             = SliderTrack

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = SliderKnob

    local s = Instance.new("UIStroke")
    s.Color     = Color3.fromRGB(50, 50, 50)
    s.Thickness = 1.5
    s.Parent    = SliderKnob
end

--[[ =========================================================
     SECTION 5 — DRAG SYSTEM (UserInputService)
     Both the icon and the menu are fully draggable.
     Position is saved so the icon reappears in the right spot.
     ========================================================= ]]

local function makeDraggable(frame, onDragEnd)
    local dragging     = false
    local dragStart    = Vector2.new()
    local startPos     = UDim2.new()

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos  = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if onDragEnd then onDragEnd(frame.Position) end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(LaunchCircle, function(pos)
    iconLastPos = pos
end)

makeDraggable(Header, function(pos)
    -- Dragging the header moves the whole menu
    -- (Header fills top of MainMenu; map its position back)
end)

-- Make the whole menu draggable via its header
do
    local dragging  = false
    local dragStart = Vector2.new()
    local startPos  = UDim2.new()

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos  = MainMenu.Position
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging    = false
            menuLastPos = MainMenu.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            MainMenu.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--[[ =========================================================
     SECTION 6 — ESP LOGIC
     Camera-facing bounding box (no flat-box bug)
     + nickname labels above each box
     ========================================================= ]]

local LINE_T = 1.5  -- line thickness in px

-- ── Box creation ──────────────────────────────────────────

local function createBox(player)
    local root = Instance.new("Frame")
    root.Name               = "ESPRoot_" .. player.Name
    root.BackgroundTransparency = 1
    root.BorderSizePixel    = 0
    root.ZIndex             = 5
    root.Parent             = ScreenGui

    local lines = {}
    for _, side in ipairs({"Top","Bottom","Left","Right"}) do
        local line = Instance.new("Frame")
        line.Name           = side
        line.BackgroundColor3 = espColor
        line.BorderSizePixel = 0
        line.ZIndex         = 6
        line.Parent         = root
        lines[side]         = line
    end

    -- Nickname label
    local nick = Instance.new("TextLabel")
    nick.Name               = "Nickname"
    nick.BackgroundTransparency = 1
    nick.Text               = player.DisplayName
    nick.TextColor3         = espColor
    nick.Font               = Enum.Font.GothamBold
    nick.TextSize           = 12
    nick.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)
    nick.TextStrokeTransparency = 0.4
    nick.ZIndex             = 7
    nick.Size               = UDim2.new(0, 120, 0, 18)
    nick.Parent             = ScreenGui

    return { root = root, lines = lines, nick = nick }
end

local function destroyBox(player)
    local box = espBoxes[player]
    if box then
        box.root:Destroy()
        box.nick:Destroy()
        espBoxes[player] = nil
    end
end

local function destroyAllBoxes()
    for player in pairs(espBoxes) do
        destroyBox(player)
    end
end

-- ── Camera-facing bounds ──────────────────────────────────
-- Projects a camera-aligned rectangle (ignores player's CFrame yaw)
-- so the box never collapses to a thin sliver when a player turns.

local function getCameraFacingBounds(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local rootPos = hrp.Position

    -- Camera right-up vectors (unit vectors on the viewport plane)
    local camCF   = Camera.CFrame
    local camRight = camCF.RightVector
    local camUp    = camCF.UpVector

    local halfW = 1.2   -- half-width in world units
    local halfH = 3.0   -- half-height in world units (approx full char)

    -- Four corners of a camera-aligned rectangle centred at rootPos
    local corners = {
        rootPos + camRight *  halfW + camUp *  halfH,
        rootPos + camRight * -halfW + camUp *  halfH,
        rootPos + camRight *  halfW + camUp * -halfH,
        rootPos + camRight * -halfW + camUp * -halfH,
    }

    local minX, minY =  math.huge,  math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false

    for _, c in ipairs(corners) do
        local sp, onScreen = Camera:WorldToViewportPoint(c)
        if onScreen then anyOnScreen = true end
        if sp.X < minX then minX = sp.X end
        if sp.X > maxX then maxX = sp.X end
        if sp.Y < minY then minY = sp.Y end
        if sp.Y > maxY then maxY = sp.Y end
    end

    -- Also check the root itself for behind-camera rejection
    local _, rootOnScreen = Camera:WorldToViewportPoint(rootPos)
    if not rootOnScreen then return nil end
    if not anyOnScreen then return nil end

    local w = maxX - minX
    local h = maxY - minY
    if w < 2 or h < 2 then return nil end

    return minX, minY, w, h
end

-- ── Box & nickname update ─────────────────────────────────

local function updateBox(box, x, y, w, h, col)
    box.root.Position = UDim2.new(0, x, 0, y)
    box.root.Size     = UDim2.new(0, w, 0, h)
    box.root.Visible  = true

    local l = box.lines
    for _, line in pairs(l) do
        line.BackgroundColor3 = col
    end

    l.Top.Size     = UDim2.new(1, 0, 0, LINE_T)
    l.Top.Position = UDim2.new(0, 0, 0, 0)

    l.Bottom.Size     = UDim2.new(1, 0, 0, LINE_T)
    l.Bottom.Position = UDim2.new(0, 0, 1, -LINE_T)

    l.Left.Size     = UDim2.new(0, LINE_T, 1, 0)
    l.Left.Position = UDim2.new(0, 0, 0, 0)

    l.Right.Size     = UDim2.new(0, LINE_T, 1, 0)
    l.Right.Position = UDim2.new(1, -LINE_T, 0, 0)

    -- Position nickname centred above the box
    local nickW = box.nick.Size.X.Offset
    box.nick.Position  = UDim2.new(0, x + (w - 2) - (nickW - 2), 0, y - 20)
    box.nick.TextColor3 = col
    box.nick.Visible   = true
end

-- ── Heartbeat loop ────────────────────────────────────────

local function startESP()
    if heartbeatConnection then return end

    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not espEnabled then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end

            local character = player.Character
            if not character then
                destroyBox(player)
                continue
            end

            local x, y, w, h = getCameraFacingBounds(character)

            if not x then
                if espBoxes[player] then
                    espBoxes[player].root.Visible = false
                    espBoxes[player].nick.Visible = false
                end
                continue
            end

            if not espBoxes[player] then
                espBoxes[player] = createBox(player)
            end

            updateBox(espBoxes[player], x, y, w, h, espColor)
        end

        -- Prune disconnected players
        for player in pairs(espBoxes) do
            if not player or not player.Parent then
                destroyBox(player)
            end
        end
    end)
end

local function stopESP()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    destroyAllBoxes()
end

Players.PlayerRemoving:Connect(destroyBox)

--[[ =========================================================
     SECTION 7 — UI INTERACTION WIRING
     ========================================================= ]]

-- ── Icon ↔ Menu toggle ────────────────────────────────────

local function showMenu()
    LaunchCircle.Visible = false
    MainMenu.Position    = menuLastPos
    MainMenu.Visible     = true
end

local function showIcon()
    menuLastPos          = MainMenu.Position
    MainMenu.Visible     = false
    LaunchCircle.Position = iconLastPos
    LaunchCircle.Visible = true
end

LaunchBtn.MouseButton1Click:Connect(showMenu)
TitleBtn.MouseButton1Click:Connect(showIcon)

-- ── Minimize ──────────────────────────────────────────────

local minimized = false

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Body.Visible     = false
        MainMenu.Size    = UDim2.new(0, MENU_W, 0, 42)
        MinBtn.Text      = "□"
    else
        Body.Visible     = true
        MainMenu.Size    = UDim2.new(0, MENU_W, 0, MENU_H)
        MinBtn.Text      = "—"
    end
end)

-- ── Close (X) — kill everything ───────────────────────────

CloseBtn.MouseButton1Click:Connect(function()
    stopESP()
    ScreenGui:Destroy()
end)

-- ── ESP Toggle ────────────────────────────────────────────

ESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPBtn.Text                    = "2D ESP (Wall)      ON"
        ESPBtn.BackgroundColor3        = Color3.fromRGB(55, 55, 55)
        ESPBtn.BackgroundTransparency  = 0.0
        startESP()
    else
        ESPBtn.Text                    = "2D ESP (Wall)      OFF"
        ESPBtn.BackgroundColor3        = Color3.fromRGB(30, 30, 30)
        ESPBtn.BackgroundTransparency  = 0.2
        destroyAllBoxes()
    end
end)

-- ── HSV Hue Slider ────────────────────────────────────────

local sliderDragging = false

local function applyHue(hue)
    espHue   = math.clamp(hue, 0, 1)
    espColor = Color3.fromHSV(espHue, 1, 1)

    -- Move knob
    local trackW = SliderTrack.AbsoluteSize.X
    local knobW  = SliderKnob.AbsoluteSize.X
    SliderKnob.Position = UDim2.new(0, math.clamp(espHue * (trackW - knobW), 0, trackW - knobW), 0, 0)

    -- Live-update all existing boxes and nicknames instantly
    for _, box in pairs(espBoxes) do
        for _, line in pairs(box.lines) do
            line.BackgroundColor3 = espColor
        end
        box.nick.TextColor3 = espColor
    end
end

local function screenXToHue(screenX)
    local trackAbs = SliderTrack.AbsolutePosition.X
    local trackW   = SliderTrack.AbsoluteSize.X
    local knobW    = SliderKnob.AbsoluteSize.X
    local rel      = (screenX - trackAbs) - (trackW - knobW)
    return math.clamp(rel, 0, 1)
end

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        applyHue(screenXToHue(input.Position.X))
    end
end)

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not sliderDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        applyHue(screenXToHue(input.Position.X))
    end
end)
