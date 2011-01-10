# == Schema Information
# Schema version: 20090915080359
#
# Table name: parameters
#
#  id            :integer(4)      not null, primary key
#  app_id        :integer(4)      default(0), not null
#  name          :string(100)     default(""), not null
#  input         :string(20)
#  kind          :string(20)
#  default_value :string(100)
#  limited       :integer(4)      default(0), not null
#

class Parameter < ActiveRecord::Base
  belongs_to :app
  has_many :parameter_values

#  def find_default_value
#    if limited == 1
#      # if limited is true it means this parameter has some
#      # predefined parameter_values. In this case default_field indicates
#      # a parameter_value id.
#      if default_value != "0" and !default_value.include?("User.") and !default_value.include?("Group.")
#        pv = parameter_values.find default_value.to_i
#        return pv.value
#      else
#        return nil
#      end
#    else
#      return default_value
#    end
#  end

  def to_label
    if app
      "#{@app.name} > #{self.name}"
    else
      self.name
    end
  end

  
  protected

  validates_associated :app

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => "app_id"

  INPUTS = ['dropdown', 'text', 'password', 'hidden']

  validates_presence_of :input
  validates_inclusion_of :input, 
                         :in => INPUTS,
                         :message => "is invalid. Use: " + INPUTS.join(", ") 

  KINDS = ['user', 'group', 'global']
  
  validates_presence_of :kind
  validates_inclusion_of :kind, 
                         :in =>  KINDS,
                         :message => "is invalid. Use: " + KINDS.join(", ") 

  def validate
    # validate that for a limited parameter, the default_value refers to an existing parameter_value
    if limited == 1 and default_value != "0" and !default_value.nil? and not default_value.include?("User.") and not default_value.include?("Group.")
      unless parameter_values.map{|pv| pv.value}.include?(default_value.to_s)
        errors.add(:default_value, "not included in possible values for this parameter")
      end
    end
  end
  
end
