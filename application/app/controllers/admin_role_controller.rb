class AdminRoleController < ApplicationController

  layout 'base' 
  before_filter :login_required
  before_filter :authorize

  private

  def authorize
    unless ["platformadmin", "privilegeduser"].include?(session[:user].role)
      flash[:notice] = "Invalid Login"
      redirect(:controller => "ims", :action => "index")
    end  
  end
  
end
