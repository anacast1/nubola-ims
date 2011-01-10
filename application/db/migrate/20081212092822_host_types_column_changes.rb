class HostTypesColumnChanges < ActiveRecord::Migration
  def self.up
    change_column :host_types, :disk,  :integer
    change_column :host_types, :price, :integer
    change_column :host_types, :ram,   :integer
    change_column :host_types, :cpu,   :integer
  end

  def self.down
    change_column :host_types, :disk,  :string
    change_column :host_types, :price, :string
    change_column :host_types, :ram,   :string
    change_column :host_types, :cpu,   :string
  end
end

