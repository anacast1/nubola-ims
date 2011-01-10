# == Schema Information
# Schema version: 20090915080359
#
# Table name: host_types
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  cpu        :integer(4)
#  ram        :integer(4)
#  disk       :integer(4)
#  price      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class HostType < ActiveRecord::Base

  include Comparable

  has_many :hosts
  validates_uniqueness_of :name

  def self.vhost_types
    HostType.find :all, :conditions => "name != 'Host compartido'"
  end

  def <=> ht
    return disk.to_i <=> ht.disk.to_i
  end

  ###### Send Xml Messages ######
  include MessageSender

  def destroy
    return false if name == "Host compartido" # tipus host compartit
    super
  end

  
  def xml4create
    to_xml
  end

  def xml4update
    to_xml
  end

  def xml4destroy
    del_vhost_type
  end

  def to_xml
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.hosttype(:name => name) {
      builder.parameters {
        builder.param(ram,   :name => "ram")
        builder.param(cpu,   :name => "cpu")
        builder.param(disk,  :name => "disk")
        builder.param(price, :name => "price")
      }
    }
  end

  def del_vhost_type
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.delhosttype(:name => name)
  end
  ##############################

  def self.required_host_type(apps)
    ram=0
    cpu=0
    disk=0
    apps.each do |app|
      ram += app.ram
      cpu += app.cpu
      disk += app.basesize
    end
    HostType.vhost_types.sort.each do |ht|
      if ram <= ht.ram and cpu <= ht.cpu and disk <= ht.disk
        return [ht,ram,cpu,disk]
      end
    end
    return [nil,ram,cpu,disk]
  end
  
end
