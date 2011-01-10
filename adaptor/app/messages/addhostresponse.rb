class Addhostresponse < Adaptation::Message
  has_one  :attribute, :gid
  has_one  :attribute, :hostname
  has_one  :object,    :status

  has_many :params,    :in => :parameters


  validates_presence_of :gid, :hostname, :status
end
