# == Schema Information
# Schema version: 20090915080359
#
# Table name: uploadedimages
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      default(0), not null
#  image      :string(255)
#  created_at :datetime
#  group_id   :integer(4)      default(0), not null
#

class Uploadedimage < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  validates_presence_of :user_id
  validates_presence_of :group_id
  file_column :image, :magick => { :versions => {:thumb => {:size => "100x100"} } } rescue Mysql::Error
end

