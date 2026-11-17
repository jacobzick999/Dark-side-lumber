-- Select a placed Lumber Tycoon 2 structure and preview rotation around its local axes.
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
assert(player, "Object rotation must run on a Roblox client")
local playerGui = player:WaitForChild("PlayerGui")

local previous = playerGui:FindFirstChild("DarkSideRotation")
if previous then
    previous:Destroy()
end

local colors = {
    background = Color3.fromRGB(22, 23, 31),
    surface = Color3.fromRGB(34, 36, 47),
    border = Color3.fromRGB(65, 66, 83),
    text = Color3.fromRGB(244, 243, 250),
    muted = Color3.fromRGB(166, 165, 183),
    accent = Color3.fromRGB(142, 110, 233),
    x = Color3.fromRGB(239, 118, 126),
    y = Color3.fromRGB(120, 203, 164),
    z = Color3.fromRGB(116, 164, 237),
}

local gui = Instance.new("ScreenGui")
gui.Name = "DarkSideRotation"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local function round(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function outline(parent, color)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Parent = parent
end

local function frame(parent, x, y, width, height, color)
    local item = Instance.new("Frame")
    item.Position = UDim2.fromOffset(x, y)
    item.Size = UDim2.fromOffset(width, height)
    item.BackgroundColor3 = color
    item.BorderSizePixel = 0
    item.Parent = parent
    return item
end

local function label(parent, text, x, y, width, height, size, color, font)
    local item = Instance.new("TextLabel")
    item.Position = UDim2.fromOffset(x, y)
    item.Size = UDim2.fromOffset(width, height)
    item.BackgroundTransparency = 1
    item.TextColor3 = color
    item.Font = font or Enum.Font.Gotham
    item.TextSize = size
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.Text = text
    item.Parent = parent
    return item
end

local function button(parent, text, x, y, width, height, color)
    local item = Instance.new("TextButton")
    item.Position = UDim2.fromOffset(x, y)
    item.Size = UDim2.fromOffset(width, height)
    item.BackgroundColor3 = color
    item.BorderSizePixel = 0
    item.TextColor3 = colors.text
    item.Font = Enum.Font.GothamBold
    item.TextSize = 13
    item.Text = text
    item.Parent = parent
    round(item, 7)
    return item
end

local panel = frame(gui, 12, 12, 312, 360, colors.background)
round(panel, 12)
outline(panel, colors.border)
local scale = Instance.new("UIScale")
scale.Parent = panel

local header = frame(panel, 0, 0, 214, 60, colors.background)
header.BackgroundTransparency = 1
header.Active = true
label(header, "DARK SIDE", 16, 10, 180, 22, 16, colors.text, Enum.Font.GothamBold)
label(header, "STRUCTURE ROTATION", 16, 32, 180, 16, 10, colors.muted, Enum.Font.GothamBold)
local minimize = button(panel, "_", 222, 14, 34, 32, colors.surface)
local close = button(panel, "X", 264, 14, 32, 32, colors.surface)

local body = frame(panel, 0, 60, 312, 300, colors.background)
body.BackgroundTransparency = 1
label(body, "PLACED STRUCTURES", 16, 6, 128, 34, 10, colors.muted, Enum.Font.GothamBold)
local selectButton = button(body, "SELECT STRUCTURE", 152, 6, 144, 34, colors.accent)
local targetCard = frame(body, 16, 50, 280, 36, colors.surface)
round(targetCard, 7)
label(targetCard, "TARGET", 10, 0, 66, 36, 10, colors.muted, Enum.Font.GothamBold)
local targetName = label(targetCard, "None selected", 76, 0, 194, 36, 13, colors.text, Enum.Font.GothamBold)
targetName.TextTruncate = Enum.TextTruncate.AtEnd

label(body, "Rotation step", 16, 96, 160, 18, 13, colors.text, Enum.Font.GothamBold)
label(body, "Degrees / local axes", 16, 114, 160, 16, 10, colors.muted)
local degreesBox = Instance.new("TextBox")
degreesBox.Position = UDim2.fromOffset(196, 96)
degreesBox.Size = UDim2.fromOffset(100, 34)
degreesBox.BackgroundColor3 = colors.surface
degreesBox.BorderSizePixel = 0
degreesBox.TextColor3 = colors.text
degreesBox.Font = Enum.Font.GothamBold
degreesBox.TextSize = 14
degreesBox.ClearTextOnFocus = false
degreesBox.Text = "15"
degreesBox.Parent = body
round(degreesBox, 7)
outline(degreesBox, colors.border)

local status = label(body, "Select a placed structure to start", 16, 264, 280, 28, 11, colors.muted)
status.TextWrapped = true
local highlight = Instance.new("Highlight")
highlight.Name = "DarkSideRotationSelection"
highlight.FillTransparency = 0.8
highlight.OutlineColor = colors.accent
highlight.Parent = workspace

local selected = nil
local selecting = false
local collapsed = false

local function clearSelection()
    selected = nil
    highlight.Adornee = nil
    targetName.Text = "None selected"
end

local function isPlacedStructure(target)
    local playerModels = workspace:FindFirstChild("PlayerModels")
    if not playerModels or not target or target.Parent ~= playerModels or not target:IsA("Model") then
        return false
    end
    local structureType = target:FindFirstChild("Type")
    return structureType and structureType:IsA("StringValue") and structureType.Value == "Structure"
        and not target:FindFirstChild("PurchasedBoxItemName") and not target:FindFirstChild("BoxItemName")
end

selectButton.Activated:Connect(function()
    selecting = not selecting
    selectButton.Text = selecting and "CANCEL" or "SELECT STRUCTURE"
    status.Text = selecting and "Click or tap a placed structure" or "Selection cancelled"
end)

local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not selecting or gameProcessed then
        return
    end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then
        status.Text = "Camera unavailable; try again"
        return
    end
    local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = player.Character and {player.Character} or {}
    local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if not hit or not hit.Instance:IsA("BasePart") then
        status.Text = "No part found; try again"
        return
    end
    local playerModels = workspace:FindFirstChild("PlayerModels")
    local target = hit.Instance
    while target and target.Parent ~= playerModels do
        target = target.Parent
    end
    if not isPlacedStructure(target) then
        status.Text = "No placed structure found; try again"
        return
    end
    selected = target
    selecting = false
    selectButton.Text = "SELECT STRUCTURE"
    highlight.Adornee = target
    targetName.Text = target.Name
    status.Text = "Use the controls below to rotate"
end)

local function rotate(axis, direction)
    if not isPlacedStructure(selected) then
        clearSelection()
        status.Text = "Select a structure first"
        return
    end
    local degrees = tonumber(degreesBox.Text)
    if not degrees or degrees ~= degrees or math.abs(degrees) > 36000 then
        status.Text = "Enter degrees between -36000 and 36000"
        return
    end
    local angle = math.rad(degrees * direction)
    local rotation = CFrame.Angles(axis == "X" and angle or 0, axis == "Y" and angle or 0, axis == "Z" and angle or 0)
    local ok = pcall(function()
        selected:PivotTo(selected:GetPivot() * rotation)
    end)
    status.Text = ok and "Local preview only; game sync unverified" or "Could not rotate this structure"
end

for index, axis in ipairs({"X", "Y", "Z"}) do
    local y = 140 + (index - 1) * 40
    local axisColor = colors[string.lower(axis)]
    label(body, axis, 20, y, 40, 34, 15, axisColor, Enum.Font.GothamBold)
    label(body, "AXIS", 43, y, 45, 34, 10, colors.muted, Enum.Font.GothamBold)
    local minus = button(body, "-", 104, y, 88, 34, colors.surface)
    local plus = button(body, "+", 200, y, 96, 34, colors.surface)
    minus.TextSize = 20
    plus.TextSize = 20
    minus.Activated:Connect(function()
        rotate(axis, -1)
    end)
    plus.Activated:Connect(function()
        rotate(axis, 1)
    end)
end

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local height = collapsed and 60 or 360
    scale.Scale = math.min(1, math.max(1, viewport.X - 24) / 312, math.max(1, viewport.Y - 64) / height)
    local maxX = math.max(0, viewport.X - 312 * scale.Scale)
    local maxY = math.max(0, viewport.Y - 36 - height * scale.Scale)
    panel.Position = UDim2.fromOffset(
        math.max(0, math.min(panel.Position.X.Offset, maxX)),
        math.max(0, math.min(panel.Position.Y.Offset, maxY))
    )
end

local cameraConnection
local function watchCamera()
    if cameraConnection then cameraConnection:Disconnect() end
    local camera = workspace.CurrentCamera
    cameraConnection = camera and camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) or nil
    updateScale()
end
local cameraChangedConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera()

minimize.Activated:Connect(function()
    collapsed = not collapsed
    body.Visible = not collapsed
    panel.Size = UDim2.fromOffset(312, collapsed and 60 or 360)
    minimize.Text = collapsed and "+" or "_"
    if collapsed then
        selecting = false
        selectButton.Text = "SELECT STRUCTURE"
    end
    updateScale()
end)

local dragStart, dragPosition, dragInput
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
        dragStart = input.Position
        dragPosition = panel.Position
    end
end)
local dragChangedConnection = UserInputService.InputChanged:Connect(function(input)
    if not dragInput then return end
    local isMouseMovement = dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
    if not isMouseMovement and input ~= dragInput then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local x = dragPosition.X.Offset + input.Position.X - dragStart.X
    local y = dragPosition.Y.Offset + input.Position.Y - dragStart.Y
    local maxX = math.max(0, camera.ViewportSize.X - panel.AbsoluteSize.X)
    local maxY = math.max(0, camera.ViewportSize.Y - panel.AbsoluteSize.Y - 36)
    panel.Position = UDim2.fromOffset(math.max(0, math.min(x, maxX)), math.max(0, math.min(y, maxY)))
end)
local dragEndedConnection = UserInputService.InputEnded:Connect(function(input)
    if input == dragInput then dragInput = nil end
end)

close.Activated:Connect(function()
    gui:Destroy()
end)
gui.Destroying:Connect(function()
    inputConnection:Disconnect()
    dragChangedConnection:Disconnect()
    dragEndedConnection:Disconnect()
    cameraChangedConnection:Disconnect()
    if cameraConnection then cameraConnection:Disconnect() end
    highlight:Destroy()
end)
