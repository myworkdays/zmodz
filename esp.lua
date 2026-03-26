-- Branded by zmods --

--[[ =========================================================
     SECTION 1: UI LIBRARY
     zmods | Project Vibe — 2D Box ESP
     ========================================================= ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ── State ──────────────────────────────────────────────────
local espEnabled = false
local espColor = Color3.fromRGB(255, 255, 255)
local espBoxes = {}
local heartbeatConnection = nil

-- ── Root GUI ───────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "zmodsESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

--[[ =========================================================
     SECTION 2: BRANDED LAUNCH ICON
     Small "zmods" circle — bottom-right, toggles the panel
     ========================================================= ]]

local LaunchCircle = Instance.new("Frame")
LaunchCircle.Name = "LaunchCircle"
LaunchCircle.Size = UDim2.new(0, 64, 0, 64)
LaunchCircle.Position = UDim2.new(1, -80, 1, -80)
LaunchCircle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LaunchCircle.BackgroundTransparency = 0.4
LaunchCircle.BorderSizePixel = 0
LaunchCircle.ZIndex = 10
LaunchCircle.Parent = ScreenGui

local LaunchCorner = Instance.new("UICorner")
LaunchCorner.CornerRadius = UDim.new(1, 0)
LaunchCorner.Parent = LaunchCircle

local LaunchLabel = Instance.new("TextLabel")
LaunchLabel.Name = "BrandLabel"
LaunchLabel.Size = UDim2.new(1, 0, 1, 0)
LaunchLabel.Position = UDim2.new(0, 0, 0, 0)
LaunchLabel.BackgroundTransparency = 1
LaunchLabel.Text = "zmods"
LaunchLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
LaunchLabel.Font = Enum.Font.GothamBold
LaunchLabel.TextSize = 13
LaunchLabel.ZIndex = 11
LaunchLabel.Parent = LaunchCircle

local LaunchButton = Instance.new("TextButton")
LaunchButton.Name = "LaunchButton"
LaunchButton.Size = UDim2.new(1, 0, 1, 0)
LaunchButton.BackgroundTransparency = 1
LaunchButton.Text = ""
LaunchButton.ZIndex = 12
LaunchButton.Parent = LaunchCircle

--[[ =========================================================
     SECTION 3: MAIN MENU (CONTROL PANEL)
     ========================================================= ]]

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 260, 0, 200)
MainMenu.Position = UDim2.new(1, -350, 1, -295)
MainMenu.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainMenu.BackgroundTransparency = 0.2
MainMenu.BorderSizePixel = 0
MainMenu.Visible = false
MainMenu.Active = true
MainMenu.Draggable = true
MainMenu.ZIndex = 20
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MainMenu

-- ── Header Bar ────────────────────────────────────────────

local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 40)
HeaderBar.Position = UDim2.new(0, 0, 0, 0)
HeaderBar.BackgroundColor3 = Color3.fromRGB(220, 130, 20)
HeaderBar.BorderSizePixel = 0
HeaderBar.ZIndex = 21
HeaderBar.Parent = MainMenu

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = HeaderBar

-- Cover the bottom rounded corners of the header
local HeaderBottomFill = Instance.new("Frame")
HeaderBottomFill.Size = UDim2.new(1, 0, 0, 10)
HeaderBottomFill.Position = UDim2.new(0, 0, 1, -10)
HeaderBottomFill.BackgroundColor3 = Color3.fromRGB(220, 130, 20)
HeaderBottomFill.BorderSizePixel = 0
HeaderBottomFill.ZIndex = 21
HeaderBottomFill.Parent = HeaderBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "zmods | Project Vibe"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 22
TitleLabel.Parent = HeaderBar

-- ── Minimize Button ───────────────────────────────────────

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -58, 0.5, -12)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 10)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 13
MinimizeBtn.ZIndex = 23
MinimizeBtn.Parent = HeaderBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 5)
MinBtnCorner.Parent = MinimizeBtn

-- ── Close Button (X) ──────────────────────────────────────

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.ZIndex = 23
CloseBtn.Parent = HeaderBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 5)
CloseBtnCorner.Parent = CloseBtn

-- ── Body ──────────────────────────────────────────────────

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, 0, 1, -40)
Body.Position = UDim2.new(0, 0, 0, 40)
Body.BackgroundTransparency = 1
Body.ZIndex = 21
Body.Parent = MainMenu

local BodyPadding = Instance.new("UIPadding")
BodyPadding.PaddingLeft = UDim.new(0, 14)
BodyPadding.PaddingRight = UDim.new(0, 14)
BodyPadding.PaddingTop = UDim.new(0, 14)
BodyPadding.PaddingBottom = UDim.new(0, 14)
BodyPadding.Parent = Body

local BodyLayout = Instance.new("UIListLayout")
BodyLayout.FillDirection = Enum.FillDirection.Vertical
BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
BodyLayout.Padding = UDim.new(0, 12)
BodyLayout.Parent = Body

-- ── ESP Toggle Button ─────────────────────────────────────

local ESPButton = Instance.new("TextButton")
ESPButton.Name = "ESPButton"
ESPButton.Size = UDim2.new(1, 0, 0, 46)
ESPButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ESPButton.BorderSizePixel = 0
ESPButton.Text = "2D ESP (Wall)  ●  OFF"
ESPButton.TextColor3 = Color3.fromRGB(160, 160, 160)
ESPButton.Font = Enum.Font.GothamBold
ESPButton.TextSize = 14
ESPButton.LayoutOrder = 1
ESPButton.ZIndex = 22
ESPButton.Parent = Body

local ESPBtnCorner = Instance.new("UICorner")
ESPBtnCorner.CornerRadius = UDim.new(0, 8)
ESPBtnCorner.Parent = ESPButton

local ESPBtnStroke = Instance.new("UIStroke")
ESPBtnStroke.Color = Color3.fromRGB(60, 60, 60)
ESPBtnStroke.Thickness = 1.5
ESPBtnStroke.Parent = ESPButton

-- ── Color Picker Row ──────────────────────────────────────

local ColorRow = Instance.new("Frame")
ColorRow.Name = "ColorRow"
ColorRow.Size = UDim2.new(1, 0, 0, 40)
ColorRow.BackgroundTransparency = 1
ColorRow.LayoutOrder = 2
ColorRow.ZIndex = 22
ColorRow.Parent = Body

local ColorRowLayout = Instance.new("UIListLayout")
ColorRowLayout.FillDirection = Enum.FillDirection.Horizontal
ColorRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
ColorRowLayout.Padding = UDim.new(0, 10)
ColorRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ColorRowLayout.Parent = ColorRow

local ColorLabel = Instance.new("TextLabel")
ColorLabel.Name = "ColorLabel"
ColorLabel.Size = UDim2.new(0, 50, 1, 0)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Color:"
ColorLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
ColorLabel.Font = Enum.Font.Gotham
ColorLabel.TextSize = 13
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.LayoutOrder = 0
ColorLabel.ZIndex = 22
ColorLabel.Parent = ColorRow

local colorOptions = {
    { name = "Red",   color = Color3.fromRGB(220, 50,  50)  },
    { name = "Green", color = Color3.fromRGB(50,  220, 80)  },
    { name = "Blue",  color = Color3.fromRGB(80,  140, 255) },
    { name = "White", color = Color3.fromRGB(255, 255, 255) },
}

local colorButtons = {}

for i, opt in ipairs(colorOptions) do
    local btn = Instance.new("TextButton")
    btn.Name = opt.name .. "ColorBtn"
    btn.Size = UDim2.new(0, 26, 0, 26)
    btn.BackgroundColor3 = opt.color
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = i
    btn.ZIndex = 23
    btn.Parent = ColorRow

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(80, 80, 80)
    btnStroke.Thickness = 1.5
    btnStroke.Name = "Stroke"
    btnStroke.Parent = btn

    colorButtons[opt.name] = { btn = btn, stroke = btnStroke, color = opt.color }
end

-- Highlight the active color button
local function updateColorHighlight(selectedName)
    for name, data in pairs(colorButtons) do
        if name == selectedName then
            data.stroke.Color = Color3.fromRGB(255, 255, 255)
            data.stroke.Thickness = 2.5
        else
            data.stroke.Color = Color3.fromRGB(80, 80, 80)
            data.stroke.Thickness = 1.5
        end
    end
end

updateColorHighlight("White")

--[[ =========================================================
     SECTION 4: ESP LOGIC
     2D Box drawing via WorldToViewportPoint + Heartbeat
     ========================================================= ]]

-- ── Box drawing helpers ───────────────────────────────────

local function createBox(player)
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "ESPBox_" .. player.Name
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 0
    boxFrame.ZIndex = 5
    boxFrame.Parent = ScreenGui

    local lines = {}
    -- top, bottom, left, right
    for _, side in ipairs({"Top", "Bottom", "Left", "Right"}) do
        local line = Instance.new("Frame")
        line.Name = side
        line.BackgroundColor3 = espColor
        line.BorderSizePixel = 0
        line.ZIndex = 6
        line.Parent = boxFrame
        lines[side] = line
    end

    return { frame = boxFrame, lines = lines }
end

local function destroyBox(player)
    local box = espBoxes[player]
    if box then
        box.frame:Destroy()
        espBoxes[player] = nil
    end
end

local function destroyAllBoxes()
    for player, _ in pairs(espBoxes) do
        destroyBox(player)
    end
end

-- Compute the on-screen 2D bounding box for a character.
-- Returns (cx, cy, width, height, onScreen) in pixels.
local function getCharacterBounds(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local rootPos = hrp.Position

    -- Approximate character height and half-width
    local halfH = 3.2
    local halfW = 1.1

    local offsets = {
        Vector3.new(-halfW,  halfH, 0),
        Vector3.new( halfW,  halfH, 0),
        Vector3.new(-halfW, -halfH, 0),
        Vector3.new( halfW, -halfH, 0),
    }

    local minX, minY =  math.huge,  math.huge
    local maxX, maxY = -math.huge, -math.huge
    local allOnScreen = true

    for _, offset in ipairs(offsets) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos + offset)
        if not onScreen then allOnScreen = false end
        if screenPos.X < minX then minX = screenPos.X end
        if screenPos.X > maxX then maxX = screenPos.X end
        if screenPos.Y < minY then minY = screenPos.Y end
        if screenPos.Y > maxY then maxY = screenPos.Y end
    end

    return minX, minY, maxX - minX, maxY - minY, allOnScreen
end

local LINE_THICKNESS = 1.5

local function updateBox(box, x, y, w, h, color)
    local f = box.frame
    local l = box.lines

    f.Position = UDim2.new(0, x, 0, y)
    f.Size = UDim2.new(0, w, 0, h)

    -- Update line colors
    for _, line in pairs(l) do
        line.BackgroundColor3 = color
    end

    -- Top
    l.Top.Size     = UDim2.new(1, 0, 0, LINE_THICKNESS)
    l.Top.Position = UDim2.new(0, 0, 0, 0)

    -- Bottom
    l.Bottom.Size     = UDim2.new(1, 0, 0, LINE_THICKNESS)
    l.Bottom.Position = UDim2.new(0, 0, 1, -LINE_THICKNESS)

    -- Left
    l.Left.Size     = UDim2.new(0, LINE_THICKNESS, 1, 0)
    l.Left.Position = UDim2.new(0, 0, 0, 0)

    -- Right
    l.Right.Size     = UDim2.new(0, LINE_THICKNESS, 1, 0)
    l.Right.Position = UDim2.new(1, -LINE_THICKNESS, 0, 0)
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

            local x, y, w, h, onScreen = getCharacterBounds(character)

            if not (x and onScreen and w > 0 and h > 0) then
                if espBoxes[player] then
                    espBoxes[player].frame.Visible = false
                end
                continue
            end

            if not espBoxes[player] then
                espBoxes[player] = createBox(player)
            end

            espBoxes[player].frame.Visible = true
            updateBox(espBoxes[player], x, y, w, h, espColor)
        end

        -- Remove boxes for players who left
        for player, _ in pairs(espBoxes) do
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

-- Clean up boxes when a player leaves
Players.PlayerRemoving:Connect(function(player)
    destroyBox(player)
end)

--[[ =========================================================
     SECTION 5: UI INTERACTION LOGIC
     ========================================================= ]]

-- Toggle ESP button
ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled

    if espEnabled then
        ESPButton.Text = "2D ESP (Wall)  ●  ON"
        ESPButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        ESPButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        ESPBtnStroke.Color = Color3.fromRGB(200, 200, 200)
        ESPBtnStroke.Thickness = 1.8
        startESP()
    else
        ESPButton.Text = "2D ESP (Wall)  ●  OFF"
        ESPButton.TextColor3 = Color3.fromRGB(160, 160, 160)
        ESPButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ESPBtnStroke.Color = Color3.fromRGB(60, 60, 60)
        ESPBtnStroke.Thickness = 1.5
        destroyAllBoxes()
    end
end)

-- Color picker buttons
for name, data in pairs(colorButtons) do
    data.btn.MouseButton1Click:Connect(function()
        espColor = data.color
        updateColorHighlight(name)

        -- Live-update existing boxes instantly
        for _, box in pairs(espBoxes) do
            for _, line in pairs(box.lines) do
                line.BackgroundColor3 = espColor
            end
        end
    end)
end

-- Minimize button — collapses the body, keeps header visible
local minimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Body.Visible = false
        MainMenu.Size = UDim2.new(0, 260, 0, 40)
        MinimizeBtn.Text = "□"
    else
        Body.Visible = true
        MainMenu.Size = UDim2.new(0, 260, 0, 200)
        MinimizeBtn.Text = "—"
    end
end)

-- Close button — destroys everything and disconnects all loops
CloseBtn.MouseButton1Click:Connect(function()
    stopESP()
    ScreenGui:Destroy()
end)

-- Launch circle toggles menu visibility
LaunchButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)
