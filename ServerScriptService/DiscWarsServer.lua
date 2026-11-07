local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("DiscWarsConfig"))

local remotes = ReplicatedStorage:FindFirstChild("DiscWarsRemotes") or Instance.new("Folder")
remotes.Name = "DiscWarsRemotes"
remotes.Parent = ReplicatedStorage

local function remote(name, className)
	local item = remotes:FindFirstChild(name) or Instance.new(className)
	item.Name = name
	item.Parent = remotes
	return item
end

local ThrowDisc = remote("ThrowDisc", "RemoteEvent")
local BuyItem = remote("BuyItem", "RemoteEvent")
local GameState = remote("GameState", "RemoteEvent")
local ShopResult = remote("ShopResult", "RemoteEvent")

local state = "Lobby"
local timeLeft = 0
local roundNumber = 0
local activePlayers = {}
local lastThrow = {}
local owned = {}
local arenaSpawns = {}
local lobbySpawn
local statusMessage = "Welcome to DISC WARS"

local function createPart(parent, name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Color = color
	part.Material = material or Enum.Material.Concrete
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function createWorld()
	local old = workspace:FindFirstChild("DiscWarsWorld")
	if old then old:Destroy() end
	local world = Instance.new("Folder")
	world.Name = "DiscWarsWorld"
	world.Parent = workspace

	local dark = Color3.fromRGB(18, 15, 25)
	local purple = Color3.fromRGB(45, 25, 62)
	local silver = Color3.fromRGB(100, 102, 115)
	local red = Color3.fromRGB(112, 37, 52)

	createPart(world, "LobbyFloor", Vector3.new(110, 2, 90), Vector3.new(0, -1, 0), dark)
	createPart(world, "LobbyBackWall", Vector3.new(110, 28, 2), Vector3.new(0, 13, 44), purple)
	createPart(world, "LobbyLeftWall", Vector3.new(2, 28, 90), Vector3.new(-54, 13, 0), dark)
	createPart(world, "LobbyRightWall", Vector3.new(2, 28, 90), Vector3.new(54, 13, 0), dark)
	createPart(world, "LobbyStage", Vector3.new(42, 2, 16), Vector3.new(0, 1, 24), red)
	createPart(world, "StageBack", Vector3.new(42, 18, 2), Vector3.new(0, 10, 32), purple)
	createPart(world, "LobbyNeonStrip", Vector3.new(38, 0.3, 0.4), Vector3.new(0, 8, 30), Color3.fromRGB(190, 50, 90), Enum.Material.Neon)
	createPart(world, "LobbySpawn", Vector3.new(8, 1, 8), Vector3.new(0, 1, -20), silver)
	lobbySpawn = world.LobbySpawn

	local arena = Instance.new("Folder")
	arena.Name = "RooftopArena"
	arena.Parent = world
	createPart(arena, "ArenaFloor", Vector3.new(82, 2, 62), Vector3.new(0, 28, -105), dark)
	createPart(arena, "NorthWall", Vector3.new(82, 12, 2), Vector3.new(0, 34, -135), purple)
	createPart(arena, "SouthWall", Vector3.new(82, 12, 2), Vector3.new(0, 34, -75), purple)
	createPart(arena, "WestWall", Vector3.new(2, 12, 62), Vector3.new(-40, 34, -105), purple)
	createPart(arena, "EastWall", Vector3.new(2, 12, 62), Vector3.new(40, 34, -105), purple)
	createPart(arena, "ArenaMark", Vector3.new(66, 0.2, 2), Vector3.new(0, 29.1, -105), red, Enum.Material.Neon)
	for index, position in ipairs({Vector3.new(-28, 30, -123), Vector3.new(28, 30, -123), Vector3.new(-28, 30, -87), Vector3.new(28, 30, -87), Vector3.new(0, 30, -105)}) do
		local spawn = createPart(arena, "ArenaSpawn" .. index, Vector3.new(5, 1, 5), position, silver)
		table.insert(arenaSpawns, spawn)
	end

	local sign = createPart(world, "ArenaSign", Vector3.new(28, 10, 1), Vector3.new(0, 9, -50), red)
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "DISC WARS\nROOFTOP ARENA"
	label.TextColor3 = Color3.fromRGB(235, 225, 235)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = surface
end

local function getCash(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	return leaderstats and leaderstats:FindFirstChild("Cash")
end

local function sendState(player)
	GameState:FireClient(player, state, timeLeft, statusMessage, roundNumber)
end

local function broadcastState()
	for _, player in ipairs(Players:GetPlayers()) do sendState(player) end
end

local function teleport(player, part)
	local character = player.Character
	if character and character.PrimaryPart then
		character:PivotTo(part.CFrame + Vector3.new(0, 4, 0))
	end
end

local function livingPlayers()
	local result = {}
	for player in pairs(activePlayers) do
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then table.insert(result, player) else activePlayers[player] = nil end
	end
	return result
end

local function createDisc(player, discId, startPosition, targetPosition)
	local data = Config.DiscTypes[discId] or Config.DiscTypes.Classic
	local disc = Instance.new("Part")
	disc.Name = "ThrownVinyl"
	disc.Shape = Enum.PartType.Cylinder
	disc.Size = Vector3.new(0.28, Config.DiscSize, Config.DiscSize)
	disc.Color = data.Color
	disc.Material = Enum.Material.Neon
	disc.CanCollide = false
	disc.CanTouch = true
	disc.CFrame = CFrame.new(startPosition) * CFrame.Angles(0, 0, math.rad(90))
	disc.Parent = workspace
	local hit = false
	local connection
	connection = disc.Touched:Connect(function(part)
		if hit then return end
		local character = part:FindFirstAncestorOfClass("Model")
		local target = character and Players:GetPlayerFromCharacter(character)
		if not target or target == player or not activePlayers[target] then return end
		hit = true
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:TakeDamage(data.Damage)
			if discId == "Electric" then
				local oldSpeed = humanoid.WalkSpeed
				humanoid.WalkSpeed = 8
				task.delay(2, function() if humanoid.Parent then humanoid.WalkSpeed = oldSpeed end end)
			end
		end
	end)
	local flightTime = (startPosition - targetPosition).Magnitude / data.Speed
	local flight = TweenService:Create(disc, TweenInfo.new(flightTime, Enum.EasingStyle.Linear), {Position = targetPosition})
	flight:Play()
	flight.Completed:Wait()
	if disc.Parent then
		local character = player.Character
		local returnPosition = character and character.PrimaryPart and character.PrimaryPart.Position or startPosition
		local returning = TweenService:Create(disc, TweenInfo.new(Config.DiscReturnTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = returnPosition})
		returning:Play()
		returning.Completed:Wait()
	end
	if connection then connection:Disconnect() end
	disc:Destroy()
end

ThrowDisc.OnServerEvent:Connect(function(player, targetPosition)
	if state ~= "Round" or not activePlayers[player] or typeof(targetPosition) ~= "Vector3" then return end
	local now = os.clock()
	if now - (lastThrow[player] or 0) < Config.ThrowCooldown then return end
	lastThrow[player] = now
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local selected = player:GetAttribute("SelectedDisc") or "Classic"
	if not owned[player] or not owned[player][selected] then selected = "Classic" end
	task.spawn(createDisc, player, selected, root.Position + root.CFrame.LookVector * 3 + Vector3.new(0, 1, 0), targetPosition)
end)

BuyItem.OnServerEvent:Connect(function(player, itemId)
	for _, item in ipairs(Config.ShopItems) do
		if item.Id == itemId then
			local cash = getCash(player)
			owned[player] = owned[player] or {Classic = true}
			if owned[player][itemId] then ShopResult:FireClient(player, false, "Already owned") return end
			if cash and cash.Value >= item.Price then
				cash.Value -= item.Price
				owned[player][itemId] = true
				if item.Category == "Disc" then player:SetAttribute("SelectedDisc", itemId) end
				ShopResult:FireClient(player, true, "Unlocked " .. item.DisplayName)
			else ShopResult:FireClient(player, false, "You need more cash") end
			return
		end
	end
end)

local function startRound()
	roundNumber += 1
	state = "Round"
	statusMessage = "Battle on the rooftop"
	activePlayers = {}
	local players = Players:GetPlayers()
	for index, player in ipairs(players) do
		activePlayers[player] = true
		player:LoadCharacter()
		task.wait()
		teleport(player, arenaSpawns[((index - 1) % #arenaSpawns) + 1])
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.MaxHealth = 100
			humanoid.Health = 100
			humanoid.Died:Connect(function() activePlayers[player] = nil end)
		end
	end
	for remaining = Config.RoundLength, 0, -1 do
		timeLeft = remaining
		broadcastState()
		if #livingPlayers() <= 1 then break end
		task.wait(1)
	end
	local winners = livingPlayers()
	if #winners > 0 then
		local winner = winners[1]
		local cash = getCash(winner)
		if cash then cash.Value += Config.WinnerReward end
		statusMessage = winner.DisplayName .. " wins! +$" .. Config.WinnerReward
	else statusMessage = "Everyone was eliminated" end
	state = "Winner"
	timeLeft = 6
	broadcastState()
	task.wait(6)
	for _, player in ipairs(Players:GetPlayers()) do teleport(player, lobbySpawn) end
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 0
	cash.Parent = leaderstats
	player:SetAttribute("SelectedDisc", "Classic")
	owned[player] = {Classic = true}
	player.CharacterAdded:Connect(function() task.wait(0.2) if state ~= "Round" then teleport(player, lobbySpawn) end end)
	sendState(player)
end)

Players.PlayerRemoving:Connect(function(player) activePlayers[player] = nil owned[player] = nil lastThrow[player] = nil end)

createWorld()
task.spawn(function()
	while true do
		state = "Intermission"
		statusMessage = "Next rooftop battle loading"
		for remaining = Config.IntermissionLength, 0, -1 do timeLeft = remaining broadcastState() task.wait(1) end
		startRound()
	end
end)
