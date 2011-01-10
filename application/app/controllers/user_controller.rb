class UserController < ApplicationController

  layout 'base'
  before_filter :login_required
  before_filter :set_user_agent
  
  def index
    @control_panel_menu = Setting.user_control_panel_menu
    render :template => "shared/controll_panel"
  end

  def user_index
    @user = User.find(session[:user].id)
  end
 
  def user_settings
    @user = User.find(session[:user].id)
    if request.post? 
      if @user.status == 'inactive'
        redirect_to :action => "user_index"
      end
      if params[:modify]
        if @user.update_attributes(params[:user])
          # send an adduser message to each user application
          apps_to_be_added_to = Array.new
          @user.apps.each do |a|
            # if the application has as a parameter some kind of
            # password transformation, also include it in this
            # adduser message in case it has changed
            parameters_hash = {} # format is: {pid => pvalue}
            pw_param =  a.parameters.find_by_name "password"
            unless pw_param.nil?
              parameters_hash[pw_param.id] = @user.send(pw_param.default_value.split(".").last.to_sym)
            end
            apps_to_be_added_to << {:application => a, :parameters => parameters_hash}
          end
          message = @user.adduser_message apps_to_be_added_to, true # this includes GENERAL
          unless system("#{Setting.oappublish} 'IMS' '#{message}'")
            logger.info("Problem publishing adduser message")
          end
          
          flash[:user_modified] = t("user") + " " + t("modifyied") + "."
          redirect_to :action => 'user_index' 
        end
      elsif params[:cancel]
        redirect_to :action => "user_index"
      elsif params[:default_image]
        @user.update_attributes(:user_image => nil)
      end
    end  
  end

  #def delete_temporal_image
  #  if session[:temp_user_image_id]
  #    TemporalUserImage.find(session[:temp_user_image_id]).destroy
  #    session[:temp_user_image_id] = nil
  #  end
  #end

  private
  def authorize
    if session[:user].role != "user"
      flash[:notice] = I18n.t("invalid_login")
      redirect(:controller => "ims", :action => "index")
    end  
  end

  def set_user_agent
    if request.respond_to?(:env_table)
      @user_agent = request.env_table["HTTP_USER_AGENT"]
    else
      @user_agent = nil
    end
  end
  
end
