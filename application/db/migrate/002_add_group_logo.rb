class AddGroupLogo < ActiveRecord::Migration
  def self.up
    add_column :groups, :logo_image, :string
  end

  def self.down
    remove_column :groups, :logo_image
  end
end
