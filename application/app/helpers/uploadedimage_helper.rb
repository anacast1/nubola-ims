module UploadedimageHelper
  def render_menu
      render :partial => 'uploadedimage/uploadedimage_header'  
  end

  def can_manage?
    return (@user.id == session[:user].id || (@user.group_id == session[:user].group_id && session[:user].groupadmin?) )
  end
end

