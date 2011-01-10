# == Schema Information
# Schema version: 20090915080359
#
# Table name: group_settings
#
#  id           :integer(4)      not null, primary key
#  group_id     :integer(4)      default(0), not null
#  parameter_id :integer(4)      default(0), not null
#  value        :string(100)     default(""), not null
#

class GroupSetting < ActiveRecord::Base
  belongs_to :group
  belongs_to :parameter
  
  def self.find_all_by_group_and_application(group,application)
    self.find(:all, :conditions => [
      "parameter_id IN (?) AND group_id = ?",
      application.parameters.map{|p| p.id}, group.id])
  end           
  
  def parameter_values
  	parameter.parameter_values.map {|pv| pv.value}
  end  

end
