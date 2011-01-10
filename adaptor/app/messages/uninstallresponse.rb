class Uninstallresponse < Adaptation::Message
  has_one  :attribute, :gid
  has_one  :attribute, :host

  has_many :apps,      :in => :applications


  validates_presence_of :gid, :host

  validates_format_of   :host, :with => /#{$config["domain"]}$/
end
