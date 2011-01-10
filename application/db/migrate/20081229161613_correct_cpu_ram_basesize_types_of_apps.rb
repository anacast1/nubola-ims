class CorrectCpuRamBasesizeTypesOfApps < ActiveRecord::Migration
  def self.up
    change_column(:apps, :ram, :integer)
    change_column(:apps, :cpu, :integer)
    change_column(:apps, :basesize, :integer)
  end

  def self.down
    change_column(:apps, :ram, :string)
    change_column(:apps, :cpu, :string)
    change_column(:apps, :basesize, :string)
  end
end
