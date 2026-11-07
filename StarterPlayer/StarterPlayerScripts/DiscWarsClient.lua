local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local Config = require(ReplicatedStorage:WaitForChild("DiscWarsConfig"))
local remotes = ReplicatedStorage:WaitForChild("DiscWarsRemotes")
local ThrowDisc = remotes:WaitForChild("ThrowDisc")
local BuyItem = remotes:WaitForChild("BuyItem")
local GameState = remotes:WaitForChild("GameState")
local ShopResult = remotes:WaitForChild("ShopResult")

local purple = Color3.fromRGB(45, 25, 62)
local red = Color3.fromRGB(130, 43, 61)
local silver = Color3.fromRGB(218, 214, 225)
local muted = Color3.fromRGB(165, 155, 175)

local gui = Instance.new("ScreenGui")
gui.Name = "DiscWarsHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function label(parent, text, size, position, color, font)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Text = text
	item.TextColor3 = color or silver
	item.Font = font or Enum.Font.Gotham
	item.TextSize = size
	item.Position = position
	item.Size = UDim2.new(1, 0, 0, size + 10)
	item.Parent = parent
	return item
end

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 92)
top.BackgroundColor3 = Color3.fromRGB(10, 8, 14)
top.BackgroundTransparency = 0.12
top.Parent = gui
local title = label(top, "DISC WARS", 26, UDim2.new(0, 24, 0, 10), silver, Enum.Font.GothamBold)
title.TextXAlignment = Enum.TextXAlignment.Left
local subtitle = label(top, "ROOFTOP VINYL BATTLES", 11, UDim2.new(0, 26, 0, 43), muted, Enum.Font.GothamMedium)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
local timer = label(top, "LOBBY", 24, UDim2.new(0.5, -100, 0, 18), silver, Enum.Font.GothamBold)
timer.Size = UDim2.new(0, 200, 0, 34)
local cashText = label(top, "$0", 20, UDim2.new(1, -170, 0, 23), Color3.fromRGB(241, 190, 55), Enum.Font.GothamBold)
cashText.Size = UDim2.new(0, 140, 0, 30)
cashText.TextXAlignment = Enum.TextXAlignment.Right

local status = label(gui, "Welcome to DISC WARS", 20, UDim2.new(0.5, -250, 0, 112), silver, Enum.Font.GothamBold)
status.Size = UDim2.new(0, 500, 0, 34)

local help = label(gui, "CLICK TO THROW  •  1-4 SELECT VINYL  •  B OPEN SHOP", 13, UDim2.new(0.5, -250, 1, -48), muted, Enum.Font.GothamMedium)
help.Size = UDim2.new(0, 500, 0, 26)

local shop = Instance.new("Frame")
shop.Name = "Shop"
shop.Size = UDim2.new(0, 380, 0, 390)
shop.Position = UDim2.new(0.5, -190, 0.5, -175)
shop.BackgroundColor3 = Color3.fromRGB(15, 11, 21)
shop.BorderColor3 = purple
shop.Visible = false
shop.Parent = gui
local shopTitle = label(shop, "THE CRATE", 24, UDim2.new(0, 20, 0, 12), silver, Enum.Font.GothamBold)
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
local shopHint = label(shop, "UNLOCK YOUR NEXT SOUND", 11, UDim2.new(0, 22, 0, 44), muted, Enum.Font.GothamMedium)
shopHint.TextXAlignment = Enum.TextXAlignment.Left
local close = Instance.new("TextButton")
close.Text = "X"
close.TextColor3 = silver
close.TextSize = 18
close.Font = Enum.Font.GothamBold
close.BackgroundColor3 = red
close.Size = UDim2.new(0, 34, 0, 30)
close.Position = UDim2.new(1, -48, 0, 14)
close.Parent = shop
close.MouseButton1Click:Connect(function() shop.Visible = false end)

local function createShopButton(item, index)
	local button = Instance.new("TextButton")
	button.Name = item.Id
	button.Text = item.DisplayName .. "   $" .. item.Price
	button.TextColor3 = silver
	button.TextSize = 14
	button.Font = Enum.Font.GothamMedium
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.BackgroundColor3 = Color3.fromRGB(34, 25, 43)
	button.Size = UDim2.new(1, -40, 0, 42)
	button.Position = UDim2.new(0, 20, 0, 78 + ((index - 1) * 50))
	button.Parent = shop
	button.MouseButton1Click:Connect(function() BuyItem:FireServer(item.Id) end)
end

for index, item in ipairs(Config.ShopItems) do createShopButton(item, index) end
local shopMessage = label(shop, "", 12, UDim2.new(0, 20, 1, -40), muted, Enum.Font.GothamMedium)
shopMessage.TextXAlignment = Enum.TextXAlignment.Left

local selected = "Classic"
local keyToDisc = {[Enum.KeyCode.One] = "Classic", [Enum.KeyCode.Two] = "Golden", [Enum.KeyCode.Three] = "Electric", [Enum.KeyCode.Four] = "Shadow"}

local function updateCash()
	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")
	if cash then cashText.Text = "$" .. cash.Value end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.B then shop.Visible = not shop.Visible return end
	if keyToDisc[input.KeyCode] then
		selected = keyToDisc[input.KeyCode]
		player:SetAttribute("SelectedDisc", selected)
		status.Text = "Selected " .. (Config.DiscTypes[selected] and Config.DiscTypes[selected].DisplayName or selected)
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not shop.Visible then
		ThrowDisc:FireServer(mouse.Hit.Position)
	end
end)

GameState.OnClientEvent:Connect(function(roundState, remaining, message)
	if roundState == "Round" then timer.Text = string.format("%02d:%02d", math.floor(remaining / 60), remaining % 60)
	elseif roundState == "Intermission" then timer.Text = "NEXT: " .. remaining
	else timer.Text = roundState:upper() end
	status.Text = message
end)

ShopResult.OnClientEvent:Connect(function(success, message)
	shopMessage.Text = message
	shopMessage.TextColor3 = success and Color3.fromRGB(110, 220, 150) or Color3.fromRGB(240, 100, 110)
	updateCash()
end)

player:GetAttributeChangedSignal("SelectedDisc"):Connect(function() selected = player:GetAttribute("SelectedDisc") or "Classic" end)
player.ChildAdded:Connect(function(child) if child.Name == "leaderstats" then child.ChildAdded:Connect(updateCash) end end)
task.spawn(function() while true do updateCash() task.wait(1) end end)
