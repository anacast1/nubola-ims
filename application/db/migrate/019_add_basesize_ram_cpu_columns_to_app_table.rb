class AddBasesizeRamCpuColumnsToAppTable < ActiveRecord::Migration

  def self.up
    add_column :apps, :basesize, :string
    add_column :apps, :ram,      :string
    add_column :apps, :cpu,      :string
  end

  def self.down
    remove_column :apps, :basesize
    remove_column :apps, :ram
    remove_column :apps, :cpu
  end

end
