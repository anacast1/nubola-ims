# == Schema Information
# Schema version: 20090915080359
#
# Table name: binds
#
#  id         :integer(4)      not null, primary key
#  app_id     :integer(4)
#  user_id    :integer(4)
#  status     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Bind < ActiveRecord::Base

  validates_presence_of :app_id, :user_id
  validates_uniqueness_of :app_id, :scope => :user_id
  belongs_to :app
  belongs_to :user

  def ready?
    return status == "OK"
  end

end
