require 'test_helper'

class ImsControllerTest < ActionController::TestCase

  test "sin session no entra" do
    get :index
    assert_redirected_to :controller => 'sso', :action => 'login'
  end

end
