require 'test_helper'

class MexControllerTest < ActionController::TestCase

  test "se entra sin session" do
    get :index
    assert_response :success
  end

  test "alta de grupo" do
    get :new_group
    assert_response :success
  end
  
  test "confirmation mail ok" do
    user = users(:noconfirmat)  
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do  
      get :confirmation, :id => user.id
    end  
    conf_email = ActionMailer::Base.deliveries.last
    assert_equal conf_email.subject, "#{I18n.t("activate_account")} #{Setting.platform_name}"
    assert_equal conf_email.to[0], user.email  
    assert_match /TU ESCRITORIO HA SIDO CREADO CORRECTAMENTE/, conf_email.body 
  end
  
end
