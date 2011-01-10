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

class Consum < Registre

  validates_presence_of :amount

  def to_label
    action + ": " + amount.to_s
  end

end
