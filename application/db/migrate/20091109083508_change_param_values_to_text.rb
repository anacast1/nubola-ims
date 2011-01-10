class ChangeParamValuesToText < ActiveRecord::Migration
  def self.up
    change_column :parameters,       :default_value, :text, :default => "", :null => false
    change_column :parameter_values, :value,         :text, :default => "", :null => false
    change_column :group_settings,   :value,         :text, :default => "", :null => false
    change_column :user_settings,    :value,         :text, :default => "", :null => false
  end

  def self.down
    change_column :parameters,       :default_value, :string, :limit => 100, :default => "", :null => false
    change_column :parameter_values, :value,         :string, :limit => 100, :default => "", :null => false
    change_column :group_settings,   :value,         :string, :limit => 100, :default => "", :null => false
    change_column :user_settings,    :value,         :string, :limit => 100, :default => "", :null => false
  end
end
