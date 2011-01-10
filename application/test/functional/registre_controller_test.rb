require 'test_helper'

class RegistreControllerTest < ActionController::TestCase

  def setup
    @request.session[:user] = users(:root)
  end

  # Los controles se acceso ya los testea RootAdminControllerTest
  
  test "index" do
    get :index
    assert_response :success
  end

end
