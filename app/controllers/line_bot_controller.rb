require 'line/bot'


# webhook_URL : https://score-log-bot.herokuapp.com/callback

class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
  
    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          response_message = if event.message['text'] == '結果'
                              Score.results
                             elsif ( event.message['text'] == 'help' || event.message['text'] == 'ヘルプ' || event.message['text'] == '使い方' || event.message['text'] == '修正' || event.message['text'] == 'しゅうせい')
                              'お役に立てたら嬉しいです！☺️'
                             else
                              Score.save_from_message(event.message['text'])
                             end
          message = {
            type: 'text',
            text: response_message
          }
          client.reply_message(event['replyToken'], message)

        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    end
  
    # Don't forget to return a successful response
    head :ok
  end

  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
