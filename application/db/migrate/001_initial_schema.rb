class InitialSchema < ActiveRecord::Migration
  def self.up

  create_table "apps", :force => true do |t|
    t.column "unique_app_id",                  :string,  :limit => 100, :default => "",    :null => false
    t.column "name",                           :string,  :limit => 100, :default => "",    :null => false
    t.column "url",                            :string,  :limit => 100
    t.column "host",                           :string,  :limit => 100
    t.column "homepage_url",                   :string,  :limit => 50
    t.column "short_description_content_type", :string,  :limit => 100
    t.column "short_description_text",         :binary
    t.column "long_description_content_type",  :string,  :limit => 100
    t.column "long_description_text",          :binary
    t.column "logo_content_type",              :string,  :limit => 100
    t.column "logo_image",                     :binary
    t.column "many_instances",                 :boolean,                :default => false, :null => false
    t.column "instance_basename",              :string,  :limit => 100
    t.column "end_user_available",             :boolean,                :default => false, :null => false
    t.column "admin_user_available",           :boolean,                :default => false, :null => false
  end

  create_table "apps_groups", :id => false, :force => true do |t|
    t.column "app_id",   :integer, :default => 0, :null => false
    t.column "group_id", :integer, :default => 0, :null => false
  end

  create_table "apps_users", :id => false, :force => true do |t|
    t.column "app_id",  :integer, :default => 0, :null => false
    t.column "user_id", :integer, :default => 0, :null => false
  end

  create_table "group_settings", :force => true do |t|
    t.column "group_id",     :integer,                :default => 0,  :null => false
    t.column "parameter_id", :integer,                :default => 0,  :null => false
    t.column "value",        :string,  :limit => 100, :default => "", :null => false
  end

   create_table "groups", :force => true do |t|
    t.column "name",            :string, :limit => 100, :default => "", :null => false
    t.column "address",         :string, :limit => 100, :default => "", :null => false
    t.column "city",            :string, :limit => 100, :default => "", :null => false
    t.column "zipcode",         :string, :limit => 5,   :default => "", :null => false
    t.column "country",         :string, :limit => 100, :default => "", :null => false
    t.column "nif",             :string, :limit => 9
    t.column "created_at",      :datetime
  end

  create_table "parameter_values", :force => true do |t|
    t.column "parameter_id",  :integer,                :default => 0,  :null => false
    t.column "value",         :string,  :limit => 100, :default => "", :null => false
  end

  create_table "parameters", :force => true do |t|
    t.column "app_id",        :integer,                :default => 0,  :null => false
    t.column "name",          :string,  :limit => 100, :default => "", :null => false
    t.column "input",         :string,  :limit => 20
    t.column "kind",          :string,  :limit => 20
    t.column "default_value", :string,  :limit => 100
    t.column "limited",       :integer,                :default => 0,  :null => false
  end

  create_table "sessions", :force => true do |t|
    t.column "sessid",     :string
    t.column "data",       :text
    t.column "updated_at", :datetime
    t.column "cookie",     :string,   :limit => 32, :default => "OApSSO", :null => false
    t.column "login",      :string,   :limit => 32, :default => "",       :null => false
  end

  create_table "temporal_user_images", :force => true do |t|
      t.column "temp_image_content_type", :string, :limit => 100
      t.column "temp_image", :binary
  end

  create_table "user_settings", :force => true do |t|
    t.column "user_id",      :integer,                :default => 0,  :null => false
    t.column "parameter_id", :integer,                :default => 0,  :null => false
    t.column "value",        :string,  :limit => 100, :default => "", :null => false
  end

  create_table "users", :force => true do |t|
    t.column "login",               :string,  :limit => 80,  :default => "",       :null => false
    t.column "password",            :string,  :limit => 40,  :default => "",       :null => false
    t.column "notes",               :text
    t.column "group_id",            :integer,                :default => 0,        :null => false
    t.column "role",                :string,  :limit => 20,  :default => "",       :null => false
    t.column "name",                :string,  :limit => 100, :default => "",       :null => false
    t.column "surname",             :string,  :limit => 100, :default => "",       :null => false
    t.column "status",              :string,  :limit => 20,  :default => "active", :null => false
    t.column "telephone",           :string,  :limit => 20
    t.column "mobile",              :string,  :limit => 20
    t.column "email",               :string,  :limit => 50,  :default => "",       :null => false
    t.column "user_image",          :binary
    t.column "plain_password",      :string,  :limit => 40,  :default => "",       :null => false
    t.column "confirmed",           :boolean,                :default => false,    :null => false
    t.column "confirmation_string", :string,  :limit => 40
    t.column "user_image_content_type", :string, :limit => 100
    t.column "wallpaper",           :string
    t.column "default_wallpaper",   :string,                 :default => "wallpaper_1.jpg"
    t.column "created_at",          :datetime
  end

  end

  def self.down
  end
end

