require 'test_helper'

class RegistreTest < ActiveSupport::TestCase
  
  fixtures :users, :groups, :apps 
  
  test "crea un registro de un login" do
    r = Registre.new  :user => users('ingent_user'), :group => groups('ingent'),  :action => 'login', :text => "<xml/>"
    r.save!
    assert_equal r, Registre.find(r)
  end
  
end
