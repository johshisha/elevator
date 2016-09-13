require 'slack'
require 'pry'
require './User.rb'

TOKEN = 'xoxb-78985393799-aMGpjloVH7QPdsMxS5X3EKDh'
Slack.configure do | conf |
  conf.token = TOKEN
end

client = Slack.realtime

@waiting_list = {34 => [], 35 => [], 36 => [], 37 => [], 38 => [],
                 38 => [], 39 => [], 40 => [], 41 => []}
@elavator_box_queue = []

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
  user = User.new(data['user'])
  if @waiting_list.has_key?(floor) then
    @waiting_list[floor].push(user)
    p user.name
    Slack.chat_postMessage(text: "呼ぶまで待っててね",
      channel: "@#{user.name}", as_user: true)
    Slack.chat_postMessage(text: "#{@waiting_list}",
      channel: "@#{user.name}", as_user: true)
    allowed_persons = check_number_of_persons(floor)
    if allowed_persons then
      @elavator_box_queue.push(allowed_persons)
      allowed_persons.each do |allowed_user|
        sendOKMessage(allowed_user.name)
      end
    end
  else
    Slack.chat_postMessage(text: "wrong floor number",
      channel: "@#{user.name}", as_user: true)
  end
end

def show_list(data)
  user = User.new(data['user'])
  lists = []
  @waiting_list.each do |key, value|
    lists.push([key, value.length])
  end
  text = ""
  lists.sort().each do | floor, person |
    text += "#{floor}階\t#{person}人\n"
  end
  Slack.chat_postMessage(text: text,
    channel: "@#{user.name}", as_user: true)
end

def sendOKMessage(userName)
  obj =  Slack.chat_postMessage(text: "次にきたエレベータに乗るべし．\n 乗ったら下のボタンを押してね．\n",
  channel: '@'+userName, as_user: true)
  ts = obj['ts']
  channel = obj['channel']
  puts Slack.reactions_add(name: 'thumbsup', channel: channel, timestamp: ts)
end

client.on :hello do
  user_list = Slack.users_list()['members']
  User.setAllUserList(user_list)
  puts 'Successfully connected.'
end

def isBoardingUser(userId)
  @elavator_box_queue[0].each do | user |
    if user.id == userId then
      return true
    end
  end
  return false
end

client.on :message do |data|
  if not data['user'] == 'U2AUZBKPH' then
    p data['text']
    if data['text'] == "list" then
      show_list(data)
      next
    end
    push_waiting_list(data)
  end
end

client.on :reaction_add do | data |
  if data['reaction'] == 'thumbsup' then
    # リアクションしたユーザがキューの先頭のユーザリストに入っていれば，キューの先頭を削除
    if isBoardingUser(data['user']) then
      @elavator_box_queue.shift()
    end
  end
end

client.start
