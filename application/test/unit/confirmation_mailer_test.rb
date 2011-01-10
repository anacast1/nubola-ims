require 'test_helper'

# http://guides.rubyonrails.org/testing.html#testing-your-mailers

class ConfirmationMailerTest < ActionMailer::TestCase

  test "confirmation" do
    user = users(:xavi)
    url = 'http://www.test.net/confirm?account=xxx'
    
    @expected.to =  user.email
    @expected.date = Time.now
    @expected.from = "#{Setting.platform_name} <#{Setting.admin_email_address}>"
    @expected.charset = "UTF-8"
    @expected.mime_version = "1.0"
    @expected.subject = "#{I18n.t("activate_account")} #{Setting.platform_name}"
    @expected.body = read_fixture('confirmation_mail')
    
    assert_equal clean(@expected.encoded), clean(ConfirmationMailer.create_confirmation(user, url).encoded)
  end

  private
  
  # Clean spaces, carriage returns and line breaks.
  # TODO: Built a fixture that looks exactly the same as
  # the mail
  def clean(str)
    str.gsub("\n", "").gsub("\r", "").gsub(" ","")
  end
  
end
