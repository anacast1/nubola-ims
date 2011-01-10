require 'test_helper'

class RootAdminControllerTest < ActionController::TestCase

  def setup
    @request.session[:user] = users(:root)
  end

  test "sin session no entra" do
    @request.session[:user] = nil
    get :index
    assert_redirected_to :controller => 'sso', :action => 'login'
  end

  test "un usuario normal no entra" do
    @request.session[:user] = users(:ingent_user) 
    get :index
    assert_redirected_to :controller => 'ims'    
  end

  test "un usuario group admin no entra" do
    @request.session[:user] = users(:groupadmin) 
    get :index
    assert_redirected_to :controller => 'ims'    
  end

  test "un privileged user no entra" do
    @request.session[:user] = users(:admin) 
    get :index
    assert_redirected_to :controller => 'ims'    
  end
  
  test "entra" do
    get :index
    assert_response :success
  end
  
end
