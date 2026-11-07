local Config = {}

Config.GameName = "DISC WARS"
Config.RoundLength = 120
Config.IntermissionLength = 12
Config.MinimumPlayers = 1
Config.WinnerReward = 100
Config.ParticipationReward = 15
Config.ThrowCooldown = 0.85
Config.DiscLifetime = 4
Config.DiscReturnTime = 0.8
Config.DiscSize = 2.2

Config.DiscTypes = {
	Classic = {
		DisplayName = "Classic Vinyl",
		Damage = 20,
		Speed = 105,
		Color = Color3.fromRGB(185, 185, 195),
		Price = 0,
		Description = "Reliable speed and damage.",
	},
	Golden = {
		DisplayName = "Golden Vinyl",
		Damage = 32,
		Speed = 95,
		Color = Color3.fromRGB(241, 190, 55),
		Price = 250,
		Description = "Higher damage for confident throws.",
	},
	Electric = {
		DisplayName = "Electric Vinyl",
		Damage = 18,
		Speed = 100,
		Color = Color3.fromRGB(63, 202, 207),
		Price = 400,
		Description = "Slows opponents briefly on impact.",
	},
	Shadow = {
		DisplayName = "Shadow Vinyl",
		Damage = 16,
		Speed = 145,
		Color = Color3.fromRGB(111, 67, 142),
		Price = 600,
		Description = "The fastest disc in the city.",
	},
}

Config.ShopItems = {
	{Id = "Golden", Category = "Disc", DisplayName = "Golden Vinyl", Price = 250},
	{Id = "Electric", Category = "Disc", DisplayName = "Electric Vinyl", Price = 400},
	{Id = "Shadow", Category = "Disc", DisplayName = "Shadow Vinyl", Price = 600},
	{Id = "StreetFit", Category = "Outfit", DisplayName = "Street Fit", Price = 300},
	{Id = "SpinThrow", Category = "Animation", DisplayName = "Spin Throw", Price = 350},
}

return Config
