Simple telegram bot that gives you the current price of the token of your choice using Pancakeswap API.


This app uses [telegram-bot](https://github.com/telegram-bot-rb/telegram-bot) gem.

To change which token price the bot gives you go to "price_bot/app/controllers/telegram_webhooks_controller.rb" and change de 'key'

## Commands

- `/start` - Greeting.
- `/price` - Get your token price
