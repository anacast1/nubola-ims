require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def test_demo_methods
    u = users(:grupclient_user)
    assert_equal(true,u.demo?)
    u.apps << apps(:crm)
    assert_equal(false,u.demo?)
  end

  def test_login
    user = User.authenticate('user','ingent')
    assert_equal users(:ingent_user), user
  end

  def test_unchecked_mail_works
    user = User.new(:login => "xavi2", 
                    :password =>"secret",
                    :password_confirmation => "secret",
                    :group_id => groups(:ingent).id,
                    :role => "user",
                    :name => "Xavi 2",
                    :surname => "Vila",
                    :email => "xavi@asd.com")
    assert !user.save
    assert_equal 1, user.errors.length
    assert_equal user.errors.on(:email), I18n.t(:activerecord)[:errors][:messages][:taken]

    user.email = Setting.unchecked_mail_address
    assert user.save
  end

  def test_name_surname_forced_to_login_if_blank
    user = User.new(:login => "xavi2", 
                    :password =>"secret",
                    :password_confirmation => "secret",
                    :group_id => groups(:ingent).id,
                    :role => "user",
                    :email => "newuser@test.org")
    assert_equal "", user.name                
    assert_equal "", user.surname
    assert user.save
    assert_equal user.name, user.login
    assert_equal user.surname, user.login                
  end
  
  def test_name_surname_not_forced_if_not_blank
    user = User.new(:login => "xavi2", 
                    :password =>"secret",
                    :password_confirmation => "secret",
                    :group_id => groups(:ingent).id,
                    :role => "user",
                    :email => "newuser@test.org",
                    :name => "testname", 
                    :surname => "testsurname")
    assert user.save
    assert_equal user.name, "testname"
    assert_equal user.surname, "testsurname"
  end
  
end
