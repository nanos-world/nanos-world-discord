DiscordIntegration = {
	webhook_id = "",
	webhook_token = "",
	use_bot_impersonation = true
}

Package.Subscribe("Load", function()
	-- Try getting from persistent data
	local persistent_data = Package.GetPersistentData()
	DiscordIntegration.webhook_id = persistent_data.discord_webhook_id
	DiscordIntegration.webhook_token = persistent_data.discord_webhook_token
	DiscordIntegration.use_bot_impersonation = persistent_data.discord_use_bot_impersonation

	-- Try getting from custom settings (overrides persistent data)
	local server_custom_settings = Server.GetCustomSettings()
	if (server_custom_settings.discord_webhook_id) then
		DiscordIntegration.webhook_id = server_custom_settings.discord_webhook_id
		Package.SetPersistentData("discord_webhook_id", DiscordIntegration.webhook_id)
	end

	if (server_custom_settings.discord_webhook_token) then
		DiscordIntegration.webhook_token = server_custom_settings.discord_webhook_token
		Package.SetPersistentData("discord_webhook_token", DiscordIntegration.webhook_token)
	end

	if (server_custom_settings.discord_use_bot_impersonation ~= nil) then
		DiscordIntegration.use_bot_impersonation = server_custom_settings.discord_use_bot_impersonation
		Package.SetPersistentData("discord_use_bot_impersonation", DiscordIntegration.use_bot_impersonation)
	end

	-- Flushes so the file is created immediately
	Package.FlushSetPersistentData()

	if (
		not DiscordIntegration.webhook_id or DiscordIntegration.webhook_id == "" or
		not DiscordIntegration.webhook_token or DiscordIntegration.webhook_token == ""
	) then
		Console.Error("Failed loading Discord Webhook ID or Token, please configure it properly in 'Packages/.data/discord.toml' or pass it via custom settings like --custom_settings\"discord_webhook_id='X', discord_webhook_token='Y'\"")
		return
	end

	-- Output Success
	Console.Log("Loaded Discord Integration successfully.")
	SendDiscordMessage("Server started!")
end)

-- Send Message
function SendDiscordMessage(message)
	local data = { allowed_mentions = { parse = {} }, content = message }

	HTTP.RequestAsync(
		"https://discord.com",
		"/api/webhooks/" .. DiscordIntegration.webhook_id .. "/" .. DiscordIntegration.webhook_token,
		HTTPMethod.POST,
		JSON.stringify(data)
	)
end

-- Send Message (impersonating with avatar and username)
function SendDiscordMessageImpersonating(content, username, avatar_url)
	local data = { allowed_mentions = { parse = {} }, username = username, avatar_url = avatar_url and avatar_url or nil, content = content }

	HTTP.RequestAsync(
		"https://discord.com",
		"/api/webhooks/" .. DiscordIntegration.webhook_id .. "/" .. DiscordIntegration.webhook_token,
		HTTPMethod.POST,
		JSON.stringify(data)
	)
end

-- Events intercept to print on Discord
Chat.Subscribe("PlayerSubmit", function(text, player)
	-- If using impersonation, then gets player avatar
	if (DiscordIntegration.use_bot_impersonation) then
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