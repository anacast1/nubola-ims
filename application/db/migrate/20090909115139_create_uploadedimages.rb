class CreateUploadedimages < ActiveRecord::Migration
  def self.up
    create_table "uploadedimages", :force => true do |t|
	  t.column "user_id",   :integer, :default => 0, :null => false
      t.column "image", :string
	  t.column "created_at", :datetime
    end
  end

  def self.down
    drop_table :uploadedimages
  end
end
