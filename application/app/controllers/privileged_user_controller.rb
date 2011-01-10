class PrivilegedUserController < ApplicationController

  layout 'base' 
  before_filter :login_required
  before_filter :authorize	
 
  def index
    @control_panel_menu = Setting.privileged_user_control_panel_menu    
    render :template => "shared/controll_panel"
  end 

  def user_index
    @user = User.find(session[:user].id)
  end
 
  def user_settings
    @user = User.find(session[:user].id)
    if request.get?
      @user.password = nil
    elsif request.post? 
      if @user.status == 'inactive'
        redirect_to :action => "user_index"
      end
      if params[:modify]
        if @user.update_attributes(params[:user])
          # send an adduser message to each user application
          apps_to_be_added_to = Array.new
          @user.apps.each do |a|
            apps_to_be_added_to << {:application => a, :parameters => {}}
          end
          message = @user.adduser_message apps_to_be_added_to, true # this includes GENERAL
          unless system("#{Setting.oappublish} 'IMS' '#{message}'")
            logger.info("Problem publishing adduser message")
          end

          redirect_to :action => 'user_index' 
        end
        @user.password = @user.password_confirmation = nil
      elsif params[:cancel]
        redirect_to :action => "user_index"
      elsif params[:default_image]
        @user.password = @user.password_confirmation = ""
        @user.update_attributes(:user_image => nil)
        @user.password = @user.password_confirmation = nil
      end
    end  
  end

  private
  
  def authorize
    if session[:user].role != "privilegeduser"
      flash[:notice] = "Invalid Login"
      redirect_to(:controller => "ims", :action => "index")
    end  
  end
end
