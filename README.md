# nanos-world-discord
nanos world Discord Webhook integration

Add the following keys in Packages/.data/discord.toml
```toml
discord_webhook_id = ""
discord_webhook_token = ""
```

Or start the server with the command-line: `--custom_settings "discord_webhook_id='X', discord_webhook_token='Y'"`

To get them, first create an webhook (https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) and copy the Webhook URL.

Then you can extract the `discord_webhook_id` and `discord_webhook_token` from the Webhook URL:

`https://discord.com/api/webhooks/<discord_webhook_id>/<discord_webhook_token>`