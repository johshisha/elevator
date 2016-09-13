require 'slack'

TOKEN = 'xoxb-78985393799-aMGpjloVH7QPdsMxS5X3EKDh'

Slack.configure do | conf |
  conf.token = TOKEN
end

client = Slack.realtime

client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|
  if not data['username'] then
    # respond to messages
    Slack.chat_postMessage(text: "#{data['text']}", channel: 'elevator_test')
  end
end

client.start
# slackに接続できたときの処理
#client.on :hello do
#  puts 'connected!'
#  client.message channel: 'elevator_test', text: 'connected!'
#end
