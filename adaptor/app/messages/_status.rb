class Status < Adaptation::Message
  has_one :attribute, :code

  has_text


  validates_presence_of :code
end





