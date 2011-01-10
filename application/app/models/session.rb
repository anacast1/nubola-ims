# == Schema Information
# Schema version: 20090915080359
#
# Table name: sessions
#
#  id         :integer(4)      not null, primary key
#  sessid     :string(255)
#  data       :text
#  updated_at :datetime
#  cookie     :string(32)      default("OApSSO"), not null
#  login      :string(32)      default(""), not null
#

class Session < ActiveRecord::Base
end
