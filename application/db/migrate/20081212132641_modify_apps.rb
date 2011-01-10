class ModifyApps < ActiveRecord::Migration
  def self.up
    add_column :apps, :description,  :text
    add_column :apps, :short,        :text
    add_column :apps, :fee,          :float
    add_column :apps, :currencycode, :string
    remove_column :apps, :host
    add_column :apps, :host_id, :integer, :default => 1
  end

  def self.down
    remove_column :apps, :description
    remove_column :apps, :short
    remove_column :apps, :fee
    remove_column :apps, :currencycode
    add_column    :apps, :host, :string, :limit => 100, :default => "saas.oaproject.net"
    remove_column :apps, :host_id
  end
end
