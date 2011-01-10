require 'test_helper'

class DesktopControllerTest < ActionController::TestCase

  def setup
    @request.session[:user] = users(:groupadmin)
  end

  test "application is present in menu if bind and install are ready" do
    get :update_menu
    assert_tag :tag => "a", :content => "Sugar CRM"
  end

  test "application is not present in menu if bind status is not OK" do 
    bind = binds(:groupadmin_crm)
    bind.status = "BINDING"
    assert bind.save
    get :update_menu
    assert_no_tag :tag => "a", :content => "Sugar CRM"
  end

  test "application is not present in menu if install status is not OK" do
    install = installs(:ingent_crm)
    install.status = "UNINSTALLING" 
    assert install.save
    get :update_menu
    assert_no_tag :tag => "a", :content => "Sugar CRM"
  end
end
