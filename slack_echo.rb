require 'slack'
require 'pry'

TOKEN = 'xoxb-78985393799-aMGpjloVH7QPdsMxS5X3EKDh'

Slack.configure do | conf |
  conf.token = TOKEN
end

client = Slack.realtime

users = Slack.users_list()['members']



client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|
  if not data['username'] then
    # respond to messages
    users.each do | user |
      if user['id'] == data['user'] then
        Slack.chat_postMessage(text: "hello @#{user['name']}",
          channel: 'elevator_test', link_names: 1, as_user: true)
      end
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
