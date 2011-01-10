class RootAdminController < RootAdminRoleController

  def index
    @control_panel_menu = Setting.root_control_panel_menu
    render :template => "shared/controll_panel"
  end 

  # ROOT USER SETTINGS

  def root_settings
    @user = User.find(session[:user].id)
    if request.get?
      if @user.user_image
        image = TemporalUserImage.create(:temp_image => @user.user_image,
                                         :temp_image_content_type => @user.user_image_content_type)
        session[:temp_user_image_id] = image.id
      else
        session[:temp_user_image_id] = nil
      end
    elsif request.post? 
      if params[:modify]
        params[:user].delete("image")
        if session[:temp_user_image_id] 
          image = TemporalUserImage.find(session[:temp_user_image_id])
          @user.user_image_content_type = image.temp_image_content_type
          @user.user_image = image.temp_image
        else
          @user.user_image = nil
        end
        if @user.update_attributes(params[:user])
          redirect_to :action => 'index' 
        end
        delete_temporal_image
        @user.password = @user.password_confirmation = nil
      elsif params[:cancel]
        redirect_to :action => 'index'
        delete_temporal_image
      elsif params[:apply_image]
        delete_temporal_image
        unless params[:user][:image].original_filename.blank?
          image = TemporalUserImage.new()
          image.image = params[:user][:image]
          if image.save
            session[:temp_user_image_id] = image.id
          end
        end
        @user.password = @user.password_confirmation = nil
      elsif params[:default_image]
        session[:temp_user_image_id] = nil
        @user.password = @user.password_confirmation = nil
      end
    end  
  end

  def delete_temporal_image
    if session[:temp_user_image_id]
      TemporalUserImage.find(session[:temp_user_image_id]).destroy
      session[:temp_user_image_id] = nil
    end
  end

end
