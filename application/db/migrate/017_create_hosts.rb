class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.column :host_type_id, :integer
      t.column :status, :string
      t.column :hostname, :string

      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :groups_hosts, :id => false do |t|
      t.column :group_id, :integer
      t.column :host_id, :integer
    end

#    vt = HostType.new
#    vt.name = "Host compartido"
#
#    host_compartit = Host.new
#    # este campo indica que es el host compartido (ver modelo):
#    host_compartit.hostname = "saas.oaproject.net"
#    host_compartit.host_type = vt
#    host_compartit.groups = Group.find :all
#    host_compartit.save!

  end

  def self.down
    drop_table :hosts
    drop_table :groups_hosts
#  rescue
#    drop_table :vhosts
#    drop_table :groups_vhosts
  end
end
