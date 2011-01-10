# == Schema Information
# Schema version: 20090915080359
#
# Table name: installs
#
#  id         :integer(4)      not null, primary key
#  app_id     :integer(4)
#  group_id   :integer(4)
#  host_id    :integer(4)
#  status     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Install < ActiveRecord::Base
  validates_presence_of :app_id, :group_id
  validates_uniqueness_of :app_id, :scope => :group_id
  belongs_to :app
  belongs_to :group
  belongs_to :host

  def validate
    errors.add(:host, "El host #{host.hostname} no esta asociado al grupo #{group.name}") unless host.group_ids.include?(group_id)
  end

  def demo?
    group.demo?
  end

  # Returns the last date of installation or nil if the
  # application is uninstalled or has never been installed.
  def self.find_install_date(app, group, status="active")
    i = find :all, :conditions => ["app_id=? AND group_id=? AND status=?",app.id,group.id,status]
    return i.first if i.size == 1
    return nil if i.size == 0
    raise "inconsistent 'installs' database"
  end

  # Returns the last day of uninstallation or nil if
  # the application is installed or has never been uninstalled.
  def self.find_uninstall_date(app, group, status="uninstalled")
    i = find :all, :conditions => ["app_id=? AND group_id=? AND status=?",app.id,group.id,status]
    return i.first if i.size == 1
    return nil if i.size == 0
    raise "inconsistent 'installs' database"
  end

  def ready?
    return status == "OK"
  end
  
  def to_label
    app.name
  end
  
end
