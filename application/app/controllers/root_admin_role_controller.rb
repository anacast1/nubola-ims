class RootAdminRoleController < ApplicationController

  layout 'base' 
  before_filter :login_required
  before_filter :authorize

  private

  def authorize
    # segun el test (root_admin_controller_test.rb "un privileged user no entra")
    # un admin no debe poder usar root_admin_controller
    # unless ["platformadmin", "privilegeduser"].include?(session[:user].role)
    unless ["platformadmin"].include?(session[:user].role)
      flash[:notice] = "Invalid Login"
      redirect_to(:controller => "ims", :action => "index")
    end  
  end
  
end
