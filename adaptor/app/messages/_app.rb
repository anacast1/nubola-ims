class AppMessage < Adaptation::Message
  maps_xml :app

  has_one  :attribute,:id 
  has_one  :object,   :status

  has_many :params 
  

  validates_presence_of :id
end
