class AmpliarSizeConfirmationString < ActiveRecord::Migration
  def self.up
	change_column(:users, :confirmation_string, :string, :limit => 255)
  end

  def self.down
	change_column(:users, :confirmation_string, :string, :limit => 40)
  end
end
