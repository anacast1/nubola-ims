require 'test_helper'

class SsoControllerTest < ActionController::TestCase
  
  fixtures :users, :groups
  
  HOST = "test.host"
  
  test "login correcto" do
    post :login, "loginBtn"=>"Iniciar sesión", :user_login => "root", :user_password => "oaroot"
    assert(@response.has_session_object?(:user))
    assert_equal users(:root), @response.session[:user]
    assert_equal("http://#{HOST}/desktop?locale=es", @response.redirect_url)
  end
  
  test "registros equivocados" do
    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "wrong" }
    assert_response(:redirect)
    post :signup, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_response(:redirect)
    post :signup, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "wrong" }
    assert_response(:redirect)
  end

  test "login incorrecto" do
    post :login, :user_login => "bob", :user_password => "not_correct"
    assert(!@response.has_session_object?(:user))
  end
  
  test "entrar y salir" do
    post :login, :user_login => "root", :user_password => "oaroot"
    assert(@response.has_session_object?(:user))
    get :logout
    assert(!@response.has_session_object?(:user))
  end

  test "un usuario sin sesion va a login" do
    get :index
    assert_response(:redirect)
    assert_redirected_to :action => 'login'
  end
  
  test "forgot_password mail ok" do
    user = users(:xavi)  
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do  
      post :forgot_password, :user_email => user.email
    end  
    pass_email = ActionMailer::Base.deliveries.last
    assert_equal pass_email.subject, "#{I18n.t("password")} #{Setting.platform_name}"
    assert_equal pass_email.to[0], user.email  
    assert_match /Estos son sus datos de acceso/, pass_email.body 
  end
  
  test "if contract with code is suspended then group is inactive" do
    user = users(:suspended_client)
    post :login, :user_login => user.login, :user_password => user.plain_password
    assert(!@response.has_session_object?(:user))
    assert_redirected_to :controller => 'sso', :action => 'login'
  end
  
end
