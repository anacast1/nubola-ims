class DesktopController < ApplicationController
  layout 'desktop', :except => ['wallpaper', 'set_wallpaper']
  before_filter :login_required

  def logout
    redirect_to :controller => :sso, :action => :logout
  end

  def update_menu
    render :layout => false
    session[:user].reload
  end

  def set_wallpaper
    @user = User.find_by_login(session[:user].login)

    if request.post?

      if params[:set_wallpaper] && !params[:fondo].nil?
        wallp=case
          when params[:fondo]=="1" : "wallpaper_1.jpg"
          when params[:fondo]=="2" : "wallpaper_2.jpg"
          when params[:fondo]=="3" : "wallpaper_3.jpg"
          when params[:fondo]=="4" : "wallpaper_4.jpg"
          when params[:fondo]=="5" : ""
        end

        if wallp.blank?  # user chose custom wallpaper
          @user.update_attributes(params[:user])
        else  #user chose built-in wallpaper
          @user.update_attributes!(:default_wallpaper => wallp, :wallpaper => nil)
        end
      end

      redirect_to :controller => "ims", :action => "index"
    end
  end

  def wallpaper
    @user = User.find_by_login(session[:user].login)
  end

end
