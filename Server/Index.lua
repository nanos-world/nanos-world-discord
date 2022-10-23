PERSISTENT_DATA = Package.GetPersistentData()

-- Parses Configuration
DISCORD_WEBHOOK_ID = PERSISTENT_DATA.DISCORD_WEBHOOK_ID
DISCORD_WEBHOOK_TOKEN = PERSISTENT_DATA.DISCORD_WEBHOOK_TOKEN

-- Verify Configuration
if (not DISCORD_WEBHOOK_ID or not DISCORD_WEBHOOK_TOKEN or DISCORD_WEBHOOK_ID == "" or DISCORD_WEBHOOK_TOKEN == "") then
	Package.Error("Failed loading Discord Webhook ID or Token")
    return
end

-- Send Message method
function SendDiscordMessage(message)
	HTTP.Request(
		"https://discord.com",
		"/api/webhooks/" .. DISCORD_WEBHOOK_ID .. "/" .. DISCORD_WEBHOOK_TOKEN,
		"POST",
		'{"allowed_mentions":{"parse":[]},"content":"' .. message .. '"}'
	)
end

-- Send Embed Message method
function SendDiscordEmbed(tEmbed)
	HTTP.Request(
		"https://discord.com",
		"/api/webhooks/" .. DISCORD_WEBHOOK_ID .. "/" .. DISCORD_WEBHOOK_TOKEN,
		"POST",
                '{"embeds":[' .. JSON.stringify(tEmbed) .. '], "allowed_mentions":{"parse":[]}}'   
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
