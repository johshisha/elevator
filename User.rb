require 'date'

class User
  attr_accessor :id
  attr_accessor :name
  attr_accessor :destination
  attr_accessor :createdAt
  @@users = nil

  def initialize(id)
    @id = id
    @createdAt = Time.now.to_i
    @name = getName(id)
  end

  def setAllUserList(user_list)
    @@users = user_list
  end

  def getName(id)
    users.each do | user |
      if user['id'] == id then
        return user['name']
      end
    end
  end

end
