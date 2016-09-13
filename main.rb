require 'slack'
require 'pry'

TOKEN = 'xoxb-78985393799-aMGpjloVH7QPdsMxS5X3EKDh'
Slack.configure do | conf |
  conf.token = TOKEN
end

client = Slack.realtime
@waiting_list = {24 => [], 25 => [], 26 => []}

class User
  def initialize(userid)
    @id = userid
    @name = 'satoshi-sanjo'
  end
end


def check(size)
  if size >= 5 and size <= 24 then
    return true
  end
  return false
end

def check_number_of_persons(floor)
  len = @waiting_list[floor].length
  keys = nil
  if check(len) then
    res = @waiting_list.delete(floor)
    @waiting_list[floor] = []
    return res
  end
  @waiting_list.each do |key, value|
    if key == floor then
      next
    end
    all_person = len + value.length
    if check(all_person) then
      keys = [floor, key]
      break
    end
  end
  res = []
  if keys then
    keys.each do | key |
      res += @waiting_list.delete(key)
      @waiting_list[key] = []
    end
    return res
  end
  return nil
end

def push_waiting_list(data)
  floor = data['text'].to_i
  if @waiting_list.has_key?(floor) then
    user = User.new(data['user'])
    @waiting_list[floor].push(user)
    # p user.name
    Slack.chat_postMessage(text: "呼ぶまで待っててね",
      channel: '@satoshi-sanjo', as_user: true)
    Slack.chat_postMessage(text: "#{@waiting_list}",
      channel: '@satoshi-sanjo', as_user: true)
    allowed_persons = check_number_of_persons(floor)
    if allowed_persons then
      p "push queue"
      Slack.chat_postMessage(text: "#{allowed_persons}",
      channel: '@satoshi-sanjo', as_user: true)
    end
  else
    Slack.chat_postMessage(text: "wrong floor number",
      channel: '@satoshi-sanjo', as_user: true)
  end
end

def show_list()
  lists = []
  @waiting_list.each do |key, value|
    lists.push([key, value.length])
  end
  text = ""
  lists.sort().each do | floor, person |
    text += "#{floor}階\t#{person}人\n"
  end
  Slack.chat_postMessage(text: text,
    channel: '@satoshi-sanjo', as_user: true)
end

def sendOKMessage(userName)
  obj =  Slack.chat_postMessage(text: "次にきたエレベータに乗るべし．\n 乗ったら下のボタンを押してね．\n",
  channel: '@'+userName, as_user: true)
  ts = obj['ts']
  channel = obj['channel']
  puts Slack.reactions_add(name: 'thumbsup', channel: channel, timestamp: ts)
end

client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|
  if not data['user'] == 'U2AUZBKPH' then
    if data['text'] == 'list' then
      show_list()
      next
    end
    push_waiting_list(data)
  end
end

client.start
