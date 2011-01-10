class Deluserresponse < Adaptation::Message
  has_one :attribute, :id
  has_one :attribute, :gid

  has_many :apps,     :in => :applications


  validates_presence_of :id, :gid
end
