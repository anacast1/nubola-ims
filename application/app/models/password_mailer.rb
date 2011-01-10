class PasswordMailer < ActionMailer::Base

  def password(user)
    @content_type = "text/plain" # "multipart/alternative"
    @subject = "#{I18n.t("password")} #{Setting.platform_name}"
    @recipients = user.email
    @sent_on = Time.now
    @from = "#{Setting.platform_name} <#{Setting.admin_email_address}>"
    @charset = "UTF-8"
    @mime_version = "1.0"
    @headers["X-Priority"] = "1"
    @headers["Content-transfer-encoding"] = "8bit"
    @body[:user] = user

    #part :content_type => "text/plain", :body => render_message("password_plain", :user => user)
    #part :content_type => "text/html",  :body => render_message("password_html", :user => user)
  end

end
