# == Schema Information
# Schema version: 20090915080359
#
# Table name: registres
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  group_id   :integer(4)
#  app_id     :integer(4)
#  action     :string(255)
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#  type       :string(255)
#  amount     :integer(4)
#

class Registre < ActiveRecord::Base

  belongs_to :user
  belongs_to :group
  belongs_to :app

  def validate
    if ["login","logout"].include? action and user.nil?
      msg = "Login o logout deben tener usuario"
      errors.add_to_base msg
      logger.info "Registre #{to_label}: #{msg}"
    end
  end
   
  def to_label
    action
  end
  
  def <=>(other)
    return created_at <=> other.created_at
  end  
  
end
