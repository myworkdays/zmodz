-- Lightweight signals and UI objects; this does not simulate Roblox rendering.
local function signal()
    local callbacks = {}
    return {
        Connect = function(_, callback)
            local connection = { Connected = true }
            function connection:Disconnect() self.Connected = false end
            table.insert(callbacks, { connection, callback })
            return connection
        end,
        Fire = function(_, ...)
            for _, entry in ipairs(callbacks) do
                if entry[1].Connected then entry[2](...) end
            end
        end,
    }
end
local function vector(x, y) return { X = x or 0, Y = y or 0 } end
local vectorMeta = { __sub = function(a, b) return vector(a.X - b.X, a.Y - b.Y) end }
Vector2 = { new = function(x, y) return setmetatable(vector(x, y), vectorMeta) end }
UDim = { new = function(scale, offset) return { Scale = scale or 0, Offset = offset or 0 } end }
UDim2 = { new = function(xs, xo, ys, yo) return { X = UDim.new(xs, xo), Y = UDim.new(ys, yo) } end }
Color3 = { fromRGB = function(...) return {...} end, fromHSV = function(...) return {...} end }
ColorSequenceKeypoint = { new = function(...) return {...} end }
ColorSequence = { new = function(...) return {...} end }
Enum = setmetatable({}, { __index = function(_, group)
    return setmetatable({}, { __index = function(_, name) return group .. '.' .. name end })
end })
Instance = { new = function(class)
    local object = {
        ClassName = class, AbsolutePosition = vector(0, 0), AbsoluteSize = vector(240, 16),
        InputBegan = signal(), InputEnded = signal(), Activated = signal(),
        MouseButton1Click = signal(),
    }
    function object:Destroy() self.destroyed = true end
    return object
end }
local inputService = { InputChanged = signal(), InputEnded = signal() }
local players = { LocalPlayer = {}, PlayerRemoving = signal(), GetPlayers = function() return {} end }
local services = { Players = players, UserInputService = inputService, CoreGui = {},
    RunService = { Heartbeat = signal() } }
game = { GetService = function(_, name) return services[name] end }
workspace = { CurrentCamera = {} }

local function pointer(kind, x, y)
    return { UserInputType = Enum.UserInputType[kind], Position = vector(x, y) }
end
local function press(button, input) button.InputBegan:Fire(input) end
local function release(button, input)
    button.InputEnded:Fire(input)
    inputService.InputEnded:Fire(input)
end
local function activate(button, input)
    button.Activated:Fire(input)
    button.MouseButton1Click:Fire()
end
-- INSERT ESP SCRIPT HERE

-- Ordinary launch, hide and minimize/restore remain available.
local click = pointer('MouseButton1', 10, 10)
press(IconBtn, click)
release(IconBtn, click)
activate(IconBtn, click)
assert(Menu.Visible and not Icon.Visible, 'Click should open the menu')
activate(MinBtn, click)
assert(not Body.Visible and Menu.Size.Y.Offset == 42, 'Minimize should hide the body')
activate(MinBtn, click)
assert(Body.Visible and Menu.Size.Y.Offset == MENU_H, 'Restore should show the body')
activate(TitleBtn, click)
assert(Icon.Visible and not Menu.Visible, 'Title click should return to the icon')

-- Dragging a button must move it without also activating its click action.
local function drag(button, target)
    local input = pointer('MouseButton1', 10, 10)
    local start = target.Position
    press(button, input)
    inputService.InputChanged:Fire(pointer('MouseMovement', 50, 60))
    assert(target.Position.X.Offset == start.X.Offset + 40, 'Dragging must move the actual button target')
    inputService.InputEnded:Fire(input)
    activate(button, input)
end
drag(IconBtn, Icon)
assert(Icon.Visible and not Menu.Visible, 'Dragging the launcher must not open the menu')
press(IconBtn, click)
release(IconBtn, click)
activate(IconBtn, click)
drag(TitleBtn, Menu)
assert(Menu.Visible and not Icon.Visible, 'Dragging the title must not hide the menu')
local last = Menu.Position
inputService.InputChanged:Fire(pointer('MouseMovement', 90, 100))
assert(Menu.Position == last, 'Releasing outside the handle must stop dragging')

-- Small pointer jitter is a click, and keyboard activation is not suppressed.
activate(TitleBtn, pointer('Keyboard', 0, 0))
assert(Icon.Visible, 'Keyboard activation should still work after dragging')
press(IconBtn, click)
local initial = Icon.Position
inputService.InputChanged:Fire(pointer('MouseMovement', 12, 12))
assert(Icon.Position == initial, 'Small click jitter must not move the launcher')
release(IconBtn, click)
activate(IconBtn, click)
assert(Menu.Visible, 'Small click jitter must not suppress activation')

-- A second finger must neither move nor release an active drag.
local touch = pointer('Touch', 10, 10)
local otherTouch = pointer('Touch', 90, 90)
press(TitleBtn, touch)
initial = Menu.Position
inputService.InputChanged:Fire(otherTouch)
inputService.InputEnded:Fire(otherTouch)
assert(Menu.Position == initial, 'Unrelated touch must not move the menu')
touch.Position = vector(30, 40)
inputService.InputChanged:Fire(touch)
assert(Menu.Position.X.Offset == initial.X.Offset + 20, 'Original touch must keep dragging')
inputService.InputEnded:Fire(touch)
activate(TitleBtn, touch)
assert(Menu.Visible, 'Touch drag must not activate the title')
last = Menu.Position
touch.Position = vector(60, 70)
inputService.InputChanged:Fire(touch)
assert(Menu.Position == last, 'Touch release must stop dragging')

-- Track clicks select the hue under the knob center, including both ends.
Track.AbsolutePosition = vector(100, 0)
Track.AbsoluteSize = vector(240, 16)
Knob.AbsoluteSize = vector(16, 16)
Track.InputBegan:Fire(pointer('MouseButton1', 220, 0))
assert(espHue == 0.5, 'Track midpoint should select the middle hue')
assert(Knob.Position.X.Offset + 8 == 120, 'Knob center should stay under the pointer')
Track.InputBegan:Fire(pointer('MouseButton1', 100, 0))
assert(espHue == 0, 'Left edge should select the first hue')
Track.InputBegan:Fire(pointer('MouseButton1', 340, 0))
assert(espHue == 1, 'Right edge should select the last hue')

activate(ESPBtn, click)
assert(espEnabled and heartbeatConn, 'Toggle should enable ESP updates')
services.RunService.Heartbeat:Fire()
activate(ESPBtn, click)
assert(not espEnabled and next(espBoxes) == nil, 'Toggle off should clear overlays')
activate(CloseBtn, click)
assert(Gui.destroyed and not heartbeatConn, 'Close should destroy the UI and stop ESP updates')

print('UI interaction regressions passed')
