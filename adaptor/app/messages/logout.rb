class Logout < Adaptation::Message
  has_one :attribute, :id
  has_one :attribute, :gid
  has_one :attribute, :sid
  has_one :attribute, :total


  validates_presence_of :id, :sid, :gid
end
