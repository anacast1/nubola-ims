class UserPasswordMustBeUniqueInGroup < ActiveRecord::Migration
  def self.up
    users   = User.find(:all)
    users.each do |user1|
      counter = 1
      users.each do |user2|
        if (user1 != user2 && user1.group_id == user2.group_id && user1.plain_password == user2.plain_password)
          user2.update_attributes!(:password => user2.plain_password + counter.to_s, :password_confirmation => user2.plain_password + counter.to_s)
          counter = counter + 1
        end
      end
    end
  end

  def self.down
    
  end
end
