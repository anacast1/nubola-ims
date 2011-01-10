# == Schema Information
# Schema version: 20090915080359
#
# Table name: consum_params
#
#  id     :integer(4)      not null, primary key
#  app_id :integer(4)      default(0), not null
#  code   :string(255)     not null
#  value  :string(255)     not null
#  name   :string(255)
#

class ConsumParam < ActiveRecord::Base

  belongs_to :app
  has_many :consum_values, :dependent => :destroy
  has_many :contracts, :through => :consum_values
  validates_presence_of :app, :code, :name
  validates_numericality_of :value

  def to_xml(margin=0)
    b = Builder::XmlMarkup.new(:indent=>2, :margin=>margin)
    xml = b.consumparam(name, :code => code)
    xml
  end

  def <=>(obj)
    code <=> obj.code
  end

  def to_label
    if app
      "#{@app.name} > #{self.name}"
    else
      self.name
    end
  end

end
