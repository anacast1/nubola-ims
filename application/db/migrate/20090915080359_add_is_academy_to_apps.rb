class AddIsAcademyToApps < ActiveRecord::Migration
  def self.up
    add_column :apps, :is_academy, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :apps, :is_academy
  end
end
