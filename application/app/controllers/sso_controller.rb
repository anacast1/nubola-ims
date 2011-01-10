class SsoController < ApplicationController
  layout  'sso' #, :except => [:login, :redirect_javascript]
  before_filter :login_required, :except =>  [:login, :index, :forgot_password]

  def index
    redirect_to :action => :login
  end

  def login
    case request.method
    when :post
      user = User.authenticate(params[:user_login], params[:user_password])
      case user
      when "group inactive"
        flash[:notice]  = I18n.t("group_is_not_active")
        flash[:login]  = params[:user_login]
        redirect_to_login and return
      when "user inactive"
        flash[:notice]  = I18n.t("user_is_not_active")
        flash[:login]  = params[:user_login]
        redirect_to_login and return
      when "login error"
        flash[:notice]  = I18n.t("invalid_login")
        flash[:login]  = params[:user_login]
        redirect_to_login and return
      when "user not confirmed"
        flash[:notice]  = I18n.t("user_is_not_confirmed")
        flash[:login]  = params[:user_login]
        redirect_to_login and return
      else
        # user succesfully authenticated
        sesss = Session.find_all_by_login(user.login)
        if(!sesss.nil?)
          sesss.each do |sess|
            if(!sess.nil?)
              user.send_logout_message(sess.sessid)
              logger.info("Logged out '#{user.login}' with '#{sess.sessid}'");
              numlogins=user.group.loginusers-1
              user.group.update_attributes(:loginusers => numlogins)

              # delete session 
              # (this asserts that the next time the user logs in he/she will be using a a different sid/cookie)
              if sess.sessid != session.session_id
                sess.destroy
              end
            end
          end
        end
        numlogins=user.group.loginusers+1
        if(user.group.numusers!=0 && numlogins>user.group.numusers && session[:user].nil?)
          flash[:notice]  = I18n.t("max_num_users_reached")
          redirect_to_login and return
        end
        user.send_login_message(session.session_id)
        user.group.update_attributes(:loginusers => numlogins)
        if session.respond_to?("model")
          session.model.login = user.login
        end
        session[:user] = user
        session.update
        flash[:notice] = I18n.t("login_failed")
        logger.info("Logged in '#{user.login}' with '#{session.session_id}'");

        # wait to let the login message arrive to the applications
        may_sleep 8

        if session[:user].group.contract.nil? || (session[:user].role == "groupadmin" && Group.find(session[:user].group_id).apps.length == 0)
          cookies[:OApcurrent] = {:value => "ims"} 
          cookies[:OApims] = {:value => "welcome_page"}
        end
        redirect_to_desktop
      end

    else

      # it's a GET
      if session[:user]
        redirect_to_desktop
      end

    end

  end


  def logout
    user = User.find_by_login(session[:user].login) # unecessary now since we added session.delete ?
    begin
      user.send_logout_message(session.session_id)
      logger.info("Logged out '#{user.login}' with '#{session.session_id}'");
    rescue => e
      logger.error("MOM not available. #{e}");
    end
    group=Group.find_by_id(user.group_id)
    numlogins=group.loginusers-1
    group.update_attributes(:loginusers => numlogins)

    # delete session 
    sess = Session.find_by_sessid(session.session_id)
    # (this asserts that the next time the user logs in he/she will be using a a different sid/cookie)
    if session.respond_to?("model")
      session.model.login = ""
    end
    session.delete
    sess.destroy if sess
    may_sleep 2

    flash[:notice] = I18n.t("session_closed")
    flash[:login] = user.login
    redirect_to_login
  end

  def forgot_password
    case request.method
    when :post
      u = nil
      if params[:user_email]
        u = User.find_by_email(params[:user_email])
      end
      if u
        email = PasswordMailer.create_password(u)
        PasswordMailer.deliver email
        flash[:notice] = I18n.t("your_password_has_been_sent_to") + h(u.email)
        redirect_to :action => "login"
      else
        flash[:notice] = I18n.t("a_user_with_email_doesnt_exist") +  h(params[:user_email])
      end
    end
  end

  private

  def redirect_to_login
      redirect_to :action => 'login'
  end
  
  def redirect_to_desktop
    if Setting.standalone
      redirect_to :controller => 'ims'
    else
      redirect_to :controller => 'desktop'
    end
  end
  
end
