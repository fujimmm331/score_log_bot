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
                              scores = event.message['text'].split(" ").map!(&:to_i)
                              scores.slice!(2, 2) if (scores.length == 4) && (scores[2] == 0) && (scores[3] == 0)
                              if valid_score_check(scores)
                                reply = ReplyService.new(scores)
                                reply.call!
                              else
                                '半角数字で送るんやでえ！あと必ず勝ち負けがつくはずやでえ！'
                              end
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

  def valid_score_check(scores)
    return false unless scores.instance_of?(Array) && (scores.length == 4 || scores.length == 2)
    scores.length == 2 ? (scores[0] != scores[1]) : (scores[0] == scores[1] && scores[2] != scores[3])
  end
end
