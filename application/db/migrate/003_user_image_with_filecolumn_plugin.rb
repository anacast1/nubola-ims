class UserImageWithFilecolumnPlugin < ActiveRecord::Migration
  def self.up
    remove_column :users, :user_image_content_type
    change_column :users, :user_image, :string
    drop_table :temporal_user_images
  end

  def self.down
    add_column :users, :user_image_content_type, :string, :limit => 100
    change_column :users, :user_image, :binary
    create_table "temporal_user_images", :force => true do |t|
      t.column "temp_image_content_type", :string, :limit => 100
      t.column "temp_image", :binary
    end
  end
end
