class Adduserresponse < Adaptation::Message
  has_one :attribute, :id
  has_one :attribute, :gid
  has_one :text,      :name
  has_one :text,      :surname
  has_one :text,      :email
  has_one :text,      :telephone
  has_one :text,      :mobile

  has_many :apps,     :in => :applications


  validates_presence_of :id, :gid
end
