require 'test_helper'

class UserControllerTest < ActionController::TestCase

  def setup
    @request.session[:user] = users(:ingent_user)
  end
  
  test "sin session no entra" do
    @request.session[:user] = nil
    get :index
    assert_redirected_to :controller => 'sso', :action => 'login'
  end

  test "con session entra" do
    get :index
    assert_response :success
  end
  
  test "user index" do
    get :user_index
    assert_response :success
  end

  test "editar usuario" do
    get :user_settings, :id => users(:ingent_user)
    assert_response :success
  end
  
end
