class UploadedimageController < ApplicationController

  layout 'base'
  before_filter :login_required

  def index
    @control_panel_menu = Setting.user_control_panel_menu
    render :template => "shared/controll_panel"
  end

  def images_index

    if session[:user].groupadmin?
      @userslist = session[:user].group.users
    else
      @userslist = Uploadedimage.find_all_by_group_id(session[:user].group_id).collect{ |uploadedimage| uploadedimage.user}.uniq
      @userslist = @userslist.push(session[:user])
      @userslist.uniq!
    end
  end

  def user_images
    if params[:id].nil?
        @user = User.find_by_id(session[:user].id)
    else
        @user = User.find_by_id(params[:id])
    end
    Uploadedimage.destroy_all(:image => nil)
    @uploadedimagelist = Uploadedimage.find_all_by_user_id(@user.id)
    if request.post? && params[:add_image]
      @uploadedimage = Uploadedimage.create!(:user_id => @user.id, :group_id => @user.group_id)
	  @uploadedimage.update_attributes(params[:uploadedimage])
      @uploadedimagelist = Uploadedimage.find_all_by_user_id(@user.id)
	end
  end

  def remove_image
    uploadedimage = Uploadedimage.find_by_id(params[:image_id])
	if request.get? && (uploadedimage.user_id == session[:user].id ||
                       (uploadedimage.group_id == session[:user].group_id && session[:user].groupadmin?) )
      uploadedimage.destroy
	end
	redirect_to :action => "user_images", :id => params[:id]
  end

end

