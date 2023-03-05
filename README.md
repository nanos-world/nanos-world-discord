# nanos-world-discord
nanos world Discord Webhook integration

Add the following keys in Packages/.data/discord.toml
```toml
DISCORD_WEBHOOK_ID = ""
DISCORD_WEBHOOK_TOKEN = ""
```

To get them, first create an webhook (https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) and copy the Webhook URL.

Then you can extract the DISCORD_WEBHOOK_ID and DISCORD_WEBHOOK_TOKEN from the Webhook URL:

`https://discord.com/api/webhooks/<DISCORD_WEBHOOK_ID>/<DISCORD_WEBHOOK_TOKEN>`