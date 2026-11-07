# Roblox Multiplayer Arena Script: Disc Wars Rooftop Vinyl

Disc Wars: Rooftop Vinyl is a Roblox multiplayer arena battle script for a dark, underground music-themed game where players throw returning vinyl records, eliminate opponents, survive timed rooftop rounds, and earn in-game cash for victories. The package includes a procedurally generated lobby and rooftop arena, server-authoritative combat, throwable boomerang-style vinyl discs, player health and elimination, round management, a cash shop, and a minimal HUD.

## Install

1. Open an existing Roblox place or create a new baseplate in Roblox Studio.
2. Create a `ModuleScript` at `ReplicatedStorage/DiscWarsConfig.lua`.
3. Create a `Script` at `ServerScriptService/DiscWarsServer.lua`.
4. Create a `LocalScript` at `StarterPlayer/StarterPlayerScripts/DiscWarsClient.lua`.
5. Copy the corresponding project files into those scripts.
6. Press Play or use Test > Start in Roblox Studio.

The server script automatically creates the `DiscWarsRemotes` folder and its RemoteEvents. It also generates the lobby, rooftop arena, arena walls, spawn points, stage, and arena sign when the server starts.

## Use

1. Start the game with Roblox Studio's Play or Test > Start tools.
2. Wait in the generated underground lobby during the intermission.
3. When the round begins, players are placed at rooftop arena spawn points.
4. Aim with the mouse and click to throw the selected vinyl.
5. Use number keys to select discs:
   - `1`: Classic Vinyl
   - `2`: Golden Vinyl
   - `3`: Electric Vinyl
   - `4`: Shadow Vinyl
6. Open or close the shop with `B`.
7. Eliminate opponents before the two-minute round ends.
8. The last living player receives the configured winner reward of `$100`.
9. Purchase additional vinyl types from the shop using earned cash.

The minimum player setting is one, allowing the systems to be tested alone. Use at least two players for the intended multiplayer battle experience. Cash and purchases are held in memory and are not persisted between server sessions.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/b6ab3056-df04-4042-8ce4-d9c602334169?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=b6ab3056-df04-4042-8ce4-d9c602334169
