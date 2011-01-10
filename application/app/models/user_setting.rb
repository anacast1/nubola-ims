# == Schema Information
# Schema version: 20090915080359
#
# Table name: user_settings
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      default(0), not null
#  parameter_id :integer(4)      default(0), not null
#  value        :string(100)     default(""), not null
#

class UserSetting < ActiveRecord::Base
  belongs_to :user
  belongs_to :parameter
  
  def self.find_all_by_user_and_application(user, application)
  	self.find(:all, :conditions => [
  	  "parameter_id IN (?) AND user_id = ?",
  	  application.parameters.map{|p| p.id}, user.id])
  end

  def parameter_values
    parameter.parameter_values.map {|pv| pv.value}
  end

  def to_label
    if parameter
      "#{parameter.to_label} = #{self.value}"
    else
      self.value
    end
  end
  
end
