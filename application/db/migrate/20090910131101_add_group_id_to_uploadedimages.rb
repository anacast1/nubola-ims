class AddGroupIdToUploadedimages < ActiveRecord::Migration
  def self.up
    add_column :uploadedimages, "group_id", :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :uploadedimages, "group_id"
  end
end
