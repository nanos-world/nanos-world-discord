PERSISTENT_DATA = Package.GetPersistentData()

-- Parses Configuration
DISCORD_WEBHOOK_ID = PERSISTENT_DATA.DISCORD_WEBHOOK_ID
DISCORD_WEBHOOK_TOKEN = PERSISTENT_DATA.DISCORD_WEBHOOK_TOKEN
DISCORD_USE_BOT_IMPERSONATION = PERSISTENT_DATA.DISCORD_USE_BOT_IMPERSONATION

-- Verify Configuration
if (
	not DISCORD_WEBHOOK_ID or DISCORD_WEBHOOK_ID == "" or
	not DISCORD_WEBHOOK_TOKEN or DISCORD_WEBHOOK_TOKEN == ""
) then
	Console.Error("Failed loading Discord Webhook ID or Token, please configure it properly in Packages/.data/discord.toml")

	-- Sets empty value so the file is created
	if (not DISCORD_WEBHOOK_ID) then
		Package.SetPersistentData("DISCORD_WEBHOOK_ID", "")
	end

	if (not DISCORD_WEBHOOK_TOKEN) then
		Package.SetPersistentData("DISCORD_WEBHOOK_TOKEN", "")
	end

	-- Flushes so the file is created immediately
	Package.FlushSetPersistentData()

	return
end

-- Defaults DISCORD_USE_BOT_IMPERSONATION to true
if (DISCORD_USE_BOT_IMPERSONATION == nil) then
	Package.SetPersistentData("DISCORD_USE_BOT_IMPERSONATION", true)
	DISCORD_USE_BOT_IMPERSONATION = true
end

-- Send Message
function SendDiscordMessage(message)
	local data = { allowed_mentions = { parse = {} }, content = message }

	HTTP.RequestAsync(
		"https://discord.com",
		"/api/webhooks/" .. DISCORD_WEBHOOK_ID .. "/" .. DISCORD_WEBHOOK_TOKEN,
		HTTPMethod.POST,
		JSON.stringify(data)
	)
end

-- Send Message (impersonating with avatar and username)
function SendDiscordMessageImpersonating(content, username, avatar_url)
	local data = { allowed_mentions = { parse = {} }, username = username, avatar_url = avatar_url and avatar_url or nil, content = content }

	HTTP.RequestAsync(
		"https://discord.com",
		"/api/webhooks/" .. DISCORD_WEBHOOK_ID .. "/" .. DISCORD_WEBHOOK_TOKEN,
		HTTPMethod.POST,
		JSON.stringify(data)
	)
end

-- Events intercept to print on Discord
Chat.Subscribe("PlayerSubmit", function(text, player)
	-- If using impersonation, then gets player avatar
	if (DISCORD_USE_BOT_IMPERSONATION) then
		local chat_cache = player:GetValue("discord::profile")

		if (chat_cache ~= nil) then
			SendDiscordMessageImpersonating(text, player:GetName(), chat_cache)
			return
		end

		-- Request to get the profile data
		HTTP.RequestAsync("https://steamcommunity.com", '/profiles/' .. player:GetSteamID() .. '/?xml=1', HTTPMethod.GET, "", "application/json", false, {}, function(status, content)
			-- Checks if profile is public and was able to get the avatar
			if (status == 200) then
				-- Get avatar url
				local avatar_url = content:match("<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>")
				SendDiscordMessageImpersonating(text, player:GetName(), avatar_url)

				-- Cache avatar url
				player:SetValue("discord::profile", avatar_url)
			else
				player:SetValue("discord::profile", false)
			end
		end)
	-- Otherwise just sends the message
	else
		SendDiscordMessage("**" .. player:GetName() .. "**: " .. text)
	end
end)

Player.Subscribe("Spawn", function(player)
	SendDiscordMessage(player:GetName() .. " has joined the server")
end)

Player.Subscribe("Destroy", function(player)
	SendDiscordMessage(player:GetName() .. " has left the server")
end)

-- Output Success
Console.Log("Loaded Discord Configuration successfuly.")
SendDiscordMessage("Server started!")