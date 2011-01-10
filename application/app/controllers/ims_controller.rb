class ImsController < ApplicationController
  before_filter :login_required
  
  def index
    case session[:user].role
      when "user"
        redirect_to :controller => "user", :action => "index"
      when "privilegeduser"
        redirect_to :controller => "privileged_user", :action => "index"
      when "groupadmin"
        redirect_to :controller => "group_admin", :action => "index"
      when "platformadmin"  
        redirect_to :controller => "root_admin", :action => "index"
    end    
  end

end

