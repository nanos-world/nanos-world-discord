PERSISTENT_DATA = Package.GetPersistentData()

-- Parses Configuration
DISCORD_WEBHOOK_ID = PERSISTENT_DATA.DISCORD_WEBHOOK_ID
DISCORD_WEBHOOK_TOKEN = PERSISTENT_DATA.DISCORD_WEBHOOK_TOKEN

-- Verify Configuration
if (not DISCORD_WEBHOOK_ID or not DISCORD_WEBHOOK_TOKEN or DISCORD_WEBHOOK_ID == "" or DISCORD_WEBHOOK_TOKEN == "") then
	Console.Error("Failed loading Discord Webhook ID or Token")
	return
end

-- Send Message method
function SendDiscordMessage(content, embed, username, avatar_url)
	local data = {allowed_mentions = {parse = {}}, username = username, avatar_url = avatar_url, content = content}

    	if embed ~= nil then
        	data['embeds'] = {JSON.parse(JSON.stringify(embed))}
    	end

    	HTTP.RequestAsync(
        	"https://discord.com",
        	"/api/webhooks/" .. DISCORD_WEBHOOK_ID .. "/" .. DISCORD_WEBHOOK_TOKEN,
        	"POST",
        	JSON.stringify(data)
    	)
end

-- Events intercept to print on Discord
Chat.Subscribe("PlayerSubmit", function(text, player)
	local steamid = player:GetSteamID()
	local chat_cache = Server.GetValue("discord_chat", {})

	if (chat_cache[steamid]) then
		SendDiscordMessage("**" .. player:GetName() .. "**: " .. text, nil, player:GetName(), chat_cache[steamid])
		return
	end

	local function sendMessage(_, content)
		-- Get avatar url
		local avatar_url = content:match("<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>")
		SendDiscordMessage("**" .. player:GetName() .. "**: " .. text, nil, player:GetName(), avatar_url)

		-- Cache avatar url
		chat_cache[steamid] = avatar_url
		Server.SetValue("discord_chat", chat_cache)
	end
	-- Request to get the profile data
	HTTP.RequestAsync("https://steamcommunity.com", '/profiles/' .. player:GetSteamID() .. '/?xml=1', "GET", nil, nil, nil, nil, sendMessage)
end)

Player.Subscribe("Spawn", function(player)
	SendDiscordMessage(player:GetName() .. " has joined the server")
end)

Player.Subscribe("Destroy", function(player)
	SendDiscordMessage(player:GetName() .. " has left the server")

	-- Remove from cache the profile avatar if exists
	local chat_cache = Server.GetValue("discord_chat", {})
	if (chat_cache[player:GetSteamID()]) then
		chat_cache[player:GetSteamID()] = nil
		Server.SetValue("discord_chat", chat_cache)
	end
end)

-- Output Success
Console.Log("Loaded Discord Configuration successfuly.")
SendDiscordMessage("Server started!")
