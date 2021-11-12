require "httparty"
require "json"
class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  def start!(*)
    respond_with :message, text: t('.content')
  end

  def price!(*)
  #Change token address here
    key = "0x1f39dd2bf5a27e2d4ed691dcf933077371777cb0"
    token_info = HTTParty.get("https://api.pancakeswap.info/api/v2/tokens/#{key}").body
    data = JSON.parse(token_info)["data"]
    if data["price"].to_f < 0.1
    price = data["price"].to_f.round(10)
    price_BNB = data["price_BNB"].to_f.round(10)
    else
    price = data["price"].to_f.round(2)
    price_BNB = data["price_BNB"].to_f.round(2)
    end
    name = data["name"]
    link = "https://pancakeswap.finance/info/token/#{key}"
    #push en ligne
    respond_with :message, text: t('.content', price: price, name: name, link: link, price_BNB: price_BNB)
  end


  def keyboard!(value = nil, *)
    if value
      respond_with :message, text: t('.selected', value: value)
    else
      save_context :keyboard!
      respond_with :message, text: t('.prompt'), reply_markup: {
        keyboard: [t('.buttons')],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true,
      }
    end
  end

  def inline_keyboard!(*)
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: [
        [
          {text: t('.alert'), callback_data: 'alert'},
          {text: t('.no_alert'), callback_data: 'no_alert'},
        ],
        [{text: t('.repo'), url: 'https://github.com/telegram-bot-rb/telegram-bot'}],
      ],
    }
  end

  def callback_query(data)
    if data == 'alert'
      answer_callback_query t('.alert'), show_alert: true
    else
      answer_callback_query t('.no_alert')
    end
  end

  def inline_query(query, _offset)
    query = query.first(10) # it's just an example, don't use large queries.
    t_description = t('.description')
    t_content = t('.content')
    results = Array.new(5) do |i|
      {
        type: :article,
        title: "#{query}-#{i}",
        id: "#{query}-#{i}",
        description: "#{t_description} #{i}",
        input_message_content: {
          message_text: "#{t_content} #{i}",
        },
      }
    end
    answer_inline_query results
  end

  # As there is no chat id in such requests, we can not respond instantly.
  # So we just save the result_id, and it's available then with `/last_chosen_inline_result`.
  def chosen_inline_result(result_id, _query)
    session[:last_chosen_inline_result] = result_id
  end

  def last_chosen_inline_result!(*)
    result_id = session[:last_chosen_inline_result]
    if result_id
      respond_with :message, text: t('.selected', result_id: result_id)
    else
      respond_with :message, text: t('.prompt')
    end
  end

  def message(message)
    respond_with :message, text: t('.content', text: message['text'])
  end

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message,
        text: t('telegram_webhooks.action_missing.command', command: action_options[:command])
    end
  end
end
