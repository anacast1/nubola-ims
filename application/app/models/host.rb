# == Schema Information
# Schema version: 20090915080359
#
# Table name: hosts
#
#  id           :integer(4)      not null, primary key
#  host_type_id :integer(4)
#  status       :string(255)
#  hostname     :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Host < ActiveRecord::Base

  has_and_belongs_to_many :groups
  belongs_to :host_type
  has_many :installs
  has_many :apps
  has_many :apps, :through => :installs

  validates_presence_of :host_type, :hostname
  validate :validate_groups
  validate :group_cant_have_two_hosts
  validates_format_of :hostname, :with => /^[\w.]+$/

  def validate_groups
    return if compartido?
    errors.add_to_base("Un servidor particular solo puede pertenecer a un grupo") if groups.size > 1
    errors.add_to_base("Un servidor particular debe pertenecer a un grupo") if groups.size < 1
  end

  def group_cant_have_two_hosts
    errors.add_to_base("Su grupo ya dispone de servidor particular") if group and group.vhost and group.vhost.id != id
  end

  
  ###### Send Xml Messages ######
  include MessageSender

  #def destroy
  #  super unless compartido?
  #end

  #def update
  #  super unless compartido?
  #end
  
  def xml4create
    return if compartido?
    addhost_message
  end
  def xml4update
    modifyhost_message
  end
  def xml4destroy
    delhost_message
  end

  def addhost_message
    return if compartido?
    # XML ADDHOST MESSAGE
    # <addhost gid="id" hostname="hostname">
    #   <parameters>
    #     <param name="ram">256</param>
    #     ...
    #   </parameters>
    # </addhost>
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.addhost("gid" => group.id, "hostname" => hostname) {
      builder.parameters {
        builder.param(host_type.cpu, "name" => "cpu")
        builder.param(host_type.ram, "name" => "ram")
        builder.param(host_type.disk, "name" => "disk")
      }
    }
  end

  def modifyhost_message
    return if compartido?
    # XML MODIFYHOST MESSAGE
    # <modifyhost gid="id" hostname="hostname">
    #   <parameters>
    #     <param name="ram">512</param>
    #     ...
    #   </parameters>
    # </modifyhost>
    builder = Builder::XmlMarkup.new(:indent=>2)
    builder.modifyhost("gid" => group.id, "hostname" => hostname) {
      builder.parameters {
        builder.param(host_type.cpu, "name" => "cpu")
        builder.param(host_type.ram, "name" => "ram")
        builder.param(host_type.disk, "name" => "disk")
      }
    }
  end

  def delhost_message
    return if compartido?
    # XML DELHOST MESSAGE
    # <delhost gid="id" hostname="hostname" />
    builder = Builder::XmlMarkup.new
    builder.delhost("gid" => group.id, "hostname" => hostname)
  end
  ###############################

  def group
    return nil if compartido?
    groups.first
  end

  def ready?
    return (status == "AVAILABLE" or status == "OK")
  end

  def to_label
    hostname
  end

  def self.hostname_compartit
    Setting.shared_host
  end

  def compartido?
    return hostname == Setting.shared_host
  end

  def virtual?
    !compartido?
  end
  
  def Host.compartido
    Host.find_by_hostname Setting.shared_host
  end

end
