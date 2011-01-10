class ConfirmationMailer < ActionMailer::Base

  def confirmation(user, url)
    @content_type = "text/plain" # "multipart/alternative"
    @subject = "#{I18n.t("activate_account")} #{Setting.platform_name}"
    @recipients = user.email
    @sent_on = Time.now
    @from = "#{Setting.platform_name} <#{Setting.admin_email_address}>"
    @charset = "UTF-8"
    @mime_version = "1.0"
    @headers["X-Priority"] = "1"
    @headers["Content-transfer-encoding"] = "8bit"
    @body[:url] = url
    
    #part :content_type => "text/plain", :body => render_message("confirmation_plain", :url => url)
    #part :content_type => "text/html",  :body => render_message("confirmation_html", :url => url)
  end

end
