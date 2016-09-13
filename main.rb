require 'slack'
require 'pry'

TOKEN = 'xoxb-78985393799-aMGpjloVH7QPdsMxS5X3EKDh'
Slack.configure do | conf |
  conf.token = TOKEN
end

client = Slack.realtime

class User
  def initialize(userid)
    @id = userid
    @name = 'satoshi-sanjo'
  end
end

waiting_list = {24 => [], 25 => [], 26 => []}

client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|
  if not data['user'] == 'U2AUZBKPH' then
    # respond to messages
    floor = data['text'].to_i
    if waiting_list.has_key?(floor) then
      user = User.new(data['user'])
      waiting_list[floor].push(user)
      # p user.name
      Slack.chat_postMessage(text: "呼ぶまで待っててね",
        channel: '@satoshi-sanjo', as_user: true)
      Slack.chat_postMessage(text: "#{waiting_list}",
        channel: '@satoshi-sanjo', as_user: true)
      p 'sent'
    else
      Slack.chat_postMessage(text: "wrong floor number",
        channel: '@satoshi-sanjo', as_user: true)
    end
    #binding.pry
  end
end

client.start
# slackに接続できたときの処理
#client.on :hello do
#  puts 'connected!'
#  client.message channel: 'elevator_test', text: 'connected!'
#end
