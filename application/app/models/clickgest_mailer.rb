class ClickgestMailer < ActionMailer::Base

  def install(group)
    content_type "text/plain"
    subject "#{group.name} installed Clickgest"
    recipients Setting.clickgest_email_destination
    sent_on Time.now
    from "#{Setting.platform_name} <#{Setting.admin_email_address}>"
    charset "UTF-8"
    mime_version "1.0"
    headers "X-Priority" => "1"
    headers "Content-transfer-encoding" => "8bit"
    body :group => group
  end

  def uninstall(group)
    content_type "text/plain"
    subject "#{group.name} uninstalled Clickgest"
    recipients Setting.clickgest_email_destination
    sent_on Time.now
    from "#{Setting.platform_name} <#{Setting.admin_email_address}>"
    charset "UTF-8"
    mime_version "1.0"
    headers "X-Priority" => "1"
    headers "Content-transfer-encoding" => "8bit"
    body :group => group
  end

end
