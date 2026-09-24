# Discord

Connect your nanos world server to a Discord channel through a Webhook. Chat messages, joins and leaves are mirrored to Discord in real time, and you can send your own messages from any package.


## Features

- Relays in-game chat to Discord
- Shows each player's name and **Steam avatar** on their messages
- Posts when the server starts and when players join or leave
- Global functions to send custom messages from your own scripts
- Mentions (`@everyone`, roles, users) are blocked, so players can't ping your server


## Setup

**1.** In Discord, open your channel settings → **Integrations** → **Webhooks** → **New Webhook**, then click **Copy Webhook URL** ([how to create a Webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)).

**2.** The URL looks like this:

```
https://discord.com/api/webhooks/<discord_webhook_id>/<discord_webhook_token>
```

**3.** Configure the ID and token using **one** of the options below.

In `Packages/.data/discord.toml` (created automatically on the first run):

```toml
discord_webhook_id = "123456789012345678"
discord_webhook_token = "abcDEF..."
discord_use_bot_impersonation = true
```

In the server `Config.toml`:

```toml
[custom_settings]
    discord_webhook_id =    "123456789012345678"
    discord_webhook_token = "abcDEF..."
```

Or through the command line:

```bash
./NanosWorldServer.exe --custom_settings "discord_webhook_id='123456789012345678', discord_webhook_token='abcDEF...'"
```

Values passed through custom settings are saved into `discord.toml`, so you only need to pass them once.

**4.** Load the package:

```toml
[game]
    packages = [
        "discord",
    ]
```


## Settings

| Setting | Default | Description |
|---|---|---|
| `discord_webhook_id` | | Your Webhook ID |
| `discord_webhook_token` | | Your Webhook token |
| `discord_use_bot_impersonation` | `true` | Posts chat messages with the player's name and Steam avatar. When `false`, messages are posted as `**Player**: message` |


## Sending your own messages

The package defines two global server functions you can call from any file inside it, or copy into your own package:

```lua
-- Simple message
SendDiscordMessage("A new round has started!")

-- Message with a custom username and avatar
SendDiscordMessageImpersonating("The zombies are coming!", "Server Bot", "https://example.com/avatar.png")
```

Example: announce kills on Discord:

```lua
Character.Subscribe("Death", function(character, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator)
	local victim = character:GetPlayer()
	if (victim and instigator) then
		SendDiscordMessage(instigator:GetName() .. " killed " .. victim:GetName())
	end
end)
```
