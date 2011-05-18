# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110511085238) do

  create_table "apps", :force => true do |t|
    t.string  "unique_app_id",        :limit => 100, :default => "",    :null => false
    t.string  "name",                 :limit => 100, :default => "",    :null => false
    t.string  "url",                  :limit => 100
    t.string  "homepage_url",         :limit => 50
    t.string  "logo_image"
    t.string  "instance_basename",    :limit => 100
    t.boolean "end_user_available",                  :default => false, :null => false
    t.boolean "admin_user_available",                :default => false, :null => false
    t.boolean "has_users",                           :default => true
    t.integer "basesize"
    t.integer "ram"
    t.integer "cpu"
    t.text    "description"
    t.text    "short"
    t.float   "fee"
    t.integer "host_id",                             :default => 1
    t.boolean "is_academy",                          :default => false, :null => false
  end

  create_table "binds", :force => true do |t|
    t.integer  "app_id"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "charges", :force => true do |t|
    t.integer  "group_id"
    t.string   "concept_type", :limit => 20
    t.date     "period_from"
    t.date     "period_to"
    t.decimal  "quantity",                   :precision => 10, :scale => 2
    t.decimal  "price",                      :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consum_params", :force => true do |t|
    t.integer "app_id", :default => 0, :null => false
    t.string  "code",                  :null => false
    t.string  "value",                 :null => false
    t.string  "name"
  end

  create_table "consum_values", :force => true do |t|
    t.integer  "consum_param_id"
    t.integer  "contract_id"
    t.boolean  "limit",           :default => true
    t.integer  "maxconsumitem"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", :force => true do |t|
    t.string   "code",                 :limit => 100, :default => "", :null => false
    t.string   "name"
    t.integer  "group_id"
    t.date     "date"
    t.string   "contract_type"
    t.string   "contact_name"
    t.string   "department"
    t.string   "mail"
    t.string   "telf"
    t.integer  "concurrentusers"
    t.boolean  "concurrentuserslimit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state",                               :default => 0
    t.string   "co_street"
    t.string   "co_cp"
    t.string   "co_town"
    t.string   "co_province"
    t.string   "co_country"
    t.string   "co_nif"
  end

  create_table "group_settings", :force => true do |t|
    t.integer "group_id",     :default => 0, :null => false
    t.integer "parameter_id", :default => 0, :null => false
    t.text    "value",                       :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name",        :limit => 100, :default => "", :null => false
    t.string   "address",     :limit => 100, :default => "", :null => false
    t.string   "city",        :limit => 100, :default => "", :null => false
    t.string   "zipcode",     :limit => 5,   :default => "", :null => false
    t.string   "country",     :limit => 100, :default => "", :null => false
    t.string   "nif",         :limit => 9
    t.datetime "created_at"
    t.string   "logo_image"
    t.integer  "numusers",                   :default => 0,  :null => false
    t.integer  "loginusers",                 :default => 0,  :null => false
    t.integer  "contract_id"
    t.datetime "demo_ends"
    t.string   "province"
    t.string   "size"
    t.string   "sector"
    t.string   "source",      :limit => 100, :default => "", :null => false
  end

  create_table "groups_hosts", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "host_id"
  end

  create_table "host_types", :force => true do |t|
    t.string   "name"
    t.integer  "cpu"
    t.integer  "ram"
    t.integer  "disk"
    t.decimal  "price",      :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hosts", :force => true do |t|
    t.integer  "host_type_id"
    t.string   "status"
    t.string   "hostname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "installs", :force => true do |t|
    t.integer  "app_id"
    t.integer  "group_id"
    t.integer  "host_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "parameter_values", :force => true do |t|
    t.integer "parameter_id", :default => 0, :null => false
    t.text    "value",                       :null => false
  end

  create_table "parameters", :force => true do |t|
    t.integer "app_id",                       :default => 0,  :null => false
    t.string  "name",          :limit => 100, :default => "", :null => false
    t.string  "input",         :limit => 20
    t.string  "kind",          :limit => 20
    t.text    "default_value",                                :null => false
    t.integer "limited",                      :default => 0,  :null => false
  end

  create_table "registres", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "app_id"
    t.string   "action"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "amount"
  end

  create_table "relationships", :id => false, :force => true do |t|
    t.integer "dependencia_id"
    t.integer "dependiente_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "sessid"
    t.text     "data"
    t.datetime "updated_at"
    t.string   "cookie",     :limit => 32, :default => "OApSSO", :null => false
    t.string   "login",      :limit => 32, :default => "",       :null => false
  end

  create_table "settings", :force => true do |t|
    t.string   "name",       :limit => 50, :default => "", :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uploadedimages", :force => true do |t|
    t.integer  "user_id",    :default => 0, :null => false
    t.string   "image"
    t.datetime "created_at"
    t.integer  "group_id",   :default => 0, :null => false
  end

  create_table "user_settings", :force => true do |t|
    t.integer "user_id",      :default => 0, :null => false
    t.integer "parameter_id", :default => 0, :null => false
    t.text    "value",                       :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",               :limit => 80,  :default => "",                :null => false
    t.string   "password_hash",       :limit => 40,  :default => "",                :null => false
    t.integer  "group_id",                           :default => 0,                 :null => false
    t.string   "role",                :limit => 20,  :default => "",                :null => false
    t.string   "name",                :limit => 100, :default => "",                :null => false
    t.string   "surname",             :limit => 100, :default => "",                :null => false
    t.string   "status",              :limit => 20,  :default => "active",          :null => false
    t.string   "telephone",           :limit => 20
    t.string   "mobile",              :limit => 20
    t.string   "email",               :limit => 50,  :default => "",                :null => false
    t.string   "user_image"
    t.string   "plain_password",      :limit => 40,  :default => "",                :null => false
    t.boolean  "confirmed",                          :default => false,             :null => false
    t.string   "confirmation_string"
    t.string   "wallpaper"
    t.string   "default_wallpaper",                  :default => "wallpaper_1.jpg"
    t.datetime "created_at"
    t.string   "identity_url"
  end

end
