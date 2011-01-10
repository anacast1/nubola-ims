require 'test_helper'

class GroupAdminControllerTest < ActionController::TestCase

  def setup
    @request.session[:user] = users(:groupadmin)
    # reset the control panel menu, because if modified in one test, keeps modified in the following ones.
    particular_server_hash = Setting.available_settings["admin_control_panel_menu"].reject{|h| h["name"] != "particular_server"}.first
    Setting.admin_control_panel_menu <<  particular_server_hash unless Setting.admin_control_panel_menu.include?(particular_server_hash)
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
 
  test "entra" do
    get :index
    assert_response :success
  end
   
  test "not displays the option to move app to host if host is not OK" do
    @request.session[:user] = users(:groupadmin)
    host = users(:groupadmin).group.vhost
    
    assert_equal host.status, "OK"
    get :app_edit, :id => users(:groupadmin).group.apps.first
    assert_tag :tag => "input", :attributes => {:type => "hidden", :id => "original_host"}
    
    host.status = "INSTALLING"
    assert host.save
    get :app_edit, :id => users(:groupadmin).group.apps.first
    assert_no_tag :tag => "input", :attributes => {:type => "hidden", :id => "original_host"}
  end
  
  test "not displays the option to choose host if host is not OK" do
    @request.session[:user] = users(:groupadmin)
    host = users(:groupadmin).group.vhost
    
    assert_equal host.status, "OK"
    get :app_install, :id => apps(:one)
    assert_tag :tag => "input", :attributes => {:type => "radio", :name => "host_id"}
    
    host.status = "INSTALLING"
    assert host.save
    get :app_install, :id => apps(:one)
    assert_no_tag :tag => "input", :attributes => {:type => "radio", :name => "host_id"}
  end
 
  test "if binding status message is correct" do
    @request.session[:user] = users(:groupadmin)
    bind = binds(:groupadmin_crm)

    bind.status = "ADDUSER_FAILED"
    assert bind.save
    get :user_bind_apps, :id => users(:groupadmin)
    assert_tag :tag => "div", :attributes => {:id => "flash"}, :content => /Este usuario esta siendo añadido a esta aplicación./
    get :app_bind_users, :id => apps(:crm)
    assert_tag :tag => "div", :attributes => {:id => "flash"}, :content => /Este usuario esta siendo añadido a esta aplicación./

    bind.status = "BINDING"
    assert bind.save
    get :user_bind_apps, :id => users(:groupadmin)
    assert_tag :tag => "div", :attributes => {:id => "flash"}, :content => /Este usuario esta siendo añadido a esta aplicación./
    get :app_bind_users, :id => apps(:crm)
    assert_tag :tag => "div", :attributes => {:id => "flash"}, :content => /Este usuario esta siendo añadido a esta aplicación./
    
    bind.status = "UNBINDING"
    assert bind.save
    get :user_bind_apps, :id => users(:groupadmin)
    assert_tag :tag => "div", :attributes => {:id => "flash"}, :content => /Este usuario esta siendo eliminado de esta aplicación./
    get :app_bind_users, :id => apps(:crm)
    assert_tag :tag => "div", :attributes => {:id => "flash"}, :content => /Este usuario esta siendo eliminado de esta aplicación./
  end

  test "particular host icon only shown for clients and when enabled in settings" do
    @request.session[:user] = users(:groupadmin)
    Setting.particular_hosts = "enabled"
    get :index
    assert_tag :tag => "img", :attributes => {:title => I18n.t("particular_server")}

    @request.session[:user] = users(:groupadmin)
    Setting.particular_hosts = "disabled"
    get :index
    assert_no_tag :tag => "img", :attributes => {:title => I18n.t("particular_server")}

    @request.session[:user] = users(:endemo_admin)
    Setting.particular_hosts = "enabled"
    get :index
    assert_no_tag :tag => "img", :attributes => {:title => I18n.t("particular_server")}

    @request.session[:user] = users(:endemo_admin)
    Setting.particular_hosts = "disabled"
    get :index
    assert_no_tag :tag => "img", :attributes => {:title => I18n.t("particular_server")}
  end

end
