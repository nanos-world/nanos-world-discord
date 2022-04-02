PERSISTENT_DATA = Package.GetPersistentData()

-- Parses Configuration
DISCORD_WEBOOK_ID = PERSISTENT_DATA.DISCORD_WEBOOK_ID
DISCORD_WEBOOK_TOKEN = PERSISTENT_DATA.DISCORD_WEBOOK_TOKEN

-- Verify Configuration
if (not DISCORD_WEBOOK_ID or not DISCORD_WEBOOK_TOKEN or DISCORD_WEBOOK_ID == "" or DISCORD_WEBOOK_TOKEN == "") then
	Package.Error("Failed loading Discord Webhook ID or Token")
    return
end

-- Send Message method
function SendDiscordMessage(message)
	HTTP.Request(
		"https://discord.com",
		"/api/webhooks/" .. DISCORD_WEBOOK_ID .. "/" .. DISCORD_WEBOOK_TOKEN,
		"POST",
		'{"content": "' .. message .. '"}'
	)
end

-- Events intercept to print on Discord
Server.Subscribe("Chat", function(text, player)
	SendDiscordMessage("**" .. player:GetName() .. "**: " .. text)
end)

Player.Subscribe("Spawn", function(player)
	SendDiscordMessage(player:GetName() .. " has joined the server")
end)

Player.Subscribe("Destroy", function(player)
	SendDiscordMessage(player:GetName() .. " has left the server")
end)

-- Output Success
Package.Log("Loaded Discord Configuration successfuly.")
SendDiscordMessage("Server started!")