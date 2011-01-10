# == Schema Information
# Schema version: 20090915080359
#
# Table name: consum_values
#
#  id              :integer(4)      not null, primary key
#  consum_param_id :integer(4)
#  contract_id     :integer(4)
#  limit           :boolean(1)      default(TRUE)
#  maxconsumitem   :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

class ConsumValue < ActiveRecord::Base
  belongs_to :contract
  belongs_to :consum_param
  validates_numericality_of :maxconsumitem
  validates_presence_of :consum_param, :contract
  validates_numericality_of :maxconsumitem

  def after_save
    contract.after_update
  end

  def after_destroy
    after_save
  end

  def to_xml(margin=0)
    b = Builder::XmlMarkup.new(:indent=>2, :margin=>margin)
    b.maxconsumitem( maxconsumitem, :code => consum_param.code, :limit => limit)
  end

  def <=>(obj)
    consum_param.code <=> obj.consum_param.code
  end

  def to_label
    consum_param.to_label + ": " + maxconsumitem.to_s
  end


end
