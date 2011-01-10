class DestroyAppLogoImage < ActiveRecord::Migration
  def self.up
   change_column :apps, :logo_image, :string
   drop_table :app_logo_images
  end

  def self.down
    create_table :app_logo_images do |t|
      t.column "app_id", :integer
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      
      # used with thumbnails, always required
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
      
      # required for images only
      t.column "width", :integer  
      t.column "height", :integer

      # required for db-based files only
      #t.column "db_file_id", :integer
    end
	
	change_column :apps, :logo_image, :binary
  end
end
