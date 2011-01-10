class DestroyShortAndLongAppDescription < ActiveRecord::Migration
  def self.up
    remove_column :apps, :short_description_content_type
    remove_column :apps, :short_description_text
    remove_column :apps, :long_description_content_type
    remove_column :apps, :long_description_text
    remove_column :apps, :logo_content_type
  
    drop_table :short_app_descriptions
    drop_table :long_app_descriptions
  end

  def self.down
    create_table :short_app_descriptions do |t|
      t.column "app_id", :integer
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      # used with thumbnails, always required
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
      
      # required for images only
      #t.column "width", :integer  
      #t.column "height", :integer

      # required for db-based files only
      #t.column "db_file_id", :integer
    end
  
    create_table :long_app_descriptions do |t|
      t.column "app_id", :integer
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      
      # used with thumbnails, always required
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
      
      # required for images only
      #t.column "width", :integer  
      #t.column "height", :integer

      # required for db-based files only
      #t.column "db_file_id", :integer
    end
	
	add_column :apps, :short_description_content_type, :string,  :limit => 100
    add_column :apps, :short_description_text,         :binary
    add_column :apps, :long_description_content_type,  :string,  :limit => 100
    add_column :apps, :long_description_text,          :binary
    add_column :apps, :logo_content_type,              :string,  :limit => 100
  end
end
