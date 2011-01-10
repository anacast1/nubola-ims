class Param < Adaptation::Message
  has_one :attribute, :name

  has_text


  validates_presence_of :name
end
