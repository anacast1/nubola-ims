class Installresponse < Adaptation::Message
  has_one  :attribute, :gid
  has_one  :attribute, :original_host
  has_one  :attribute, :host

  has_many :apps,      :in => :applications


  validates_presence_of :gid, :original_host, :host

  validates_format_of   :original_host, :with => /#{$config["domain"]}$/
  validates_format_of   :host,          :with => /#{$config["domain"]}$/
end
