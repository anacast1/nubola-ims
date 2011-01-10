# == Schema Information
# Schema version: 20090915080359
#
# Table name: parameter_values
#
#  id           :integer(4)      not null, primary key
#  parameter_id :integer(4)      default(0), not null
#  value        :string(100)     default(""), not null
#

class ParameterValue < ActiveRecord::Base
  belongs_to :parameter

  validates_associated :parameter

  validates_presence_of :value

  def to_label
    value
  end
  
end
