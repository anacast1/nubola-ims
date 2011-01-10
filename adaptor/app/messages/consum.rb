class ConsumMessage < Adaptation::Message
  maps_xml :consum

  has_one  :attribute, :gid
  has_one  :attribute, :app_id
  has_many :consumitems

  validates_presence_of :gid, :app_id
end
