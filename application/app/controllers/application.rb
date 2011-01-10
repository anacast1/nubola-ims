require_dependency "login_system"

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ERB::Util # to allow html escape (i.e h(...)) strings in controllers
  include ExceptionNotifiable
  local_addresses.clear

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => 'c8734c8a35440aa8fc96f35c4c055d03'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  include LoginSystem

  before_filter :set_locale

  # move to the last store_location call or to the passed default one
  def redirect_back_or_welcome(welcome_action)
    if session[:return_to].nil?
      redirect_to welcome_action
    else
      redirect_to_url session[:return_to]
      session[:return_to] = nil
    end
  end
  
  #around_filter :set_language

  def check_is_root_or_admin
    user = User.find(session[:user].id)
    unless ["privilegeduser", "platformadmin"].include? user.role
      redirect_to :controller => "ims"
    end
  end

  def check_is_group_admin
    user = User.find(session[:user].id)
    unless user == user.group.admin
      redirect_to :controller => "ims"
    end
  end

  def render_to_pdf(options = nil)
    data = render_to_string(options)
    pdf = PDF::HTMLDoc.new
    pdf.set_option :bodycolor, :white
    pdf.set_option :toc, false
    pdf.set_option :portrait, true
    pdf.set_option :links, true
    pdf.set_option :webpage, true
    pdf.set_option :left, '2cm'
    pdf.set_option :right, '2cm'
    pdf.set_option :bodyfont, 'Arial'
    pdf.set_option :footer, '..:'
    pdf << data
    pdf.generate
  end

  private

 # def set_language
 #   # right now IMS is only translated to spanish
 #   Gibberish.use_language(:es) { yield }
 # end

  def set_locale 
    unless ['es', 'ca', 'en'].include? params[:locale]
      params[:locale] = I18n.default_locale
    end
    I18n.locale = params[:locale]   
  end

  def default_url_options(options={}) 
    # logger.debug "default_url_options is passed options: #{options.inspect}\n"  
    { :locale => I18n.locale } 
  end

  def standalone?
    Setting.standalone
  end
  
  def may_sleep(s=nil)
    s = s || 2
    sleep s unless standalone?
    logger.info("TODO WARNING: sleeping #{s} seconds! Sleeping is deprecated and will be removed in IMS 2.0. Use a response message instead! :D") if s > 2
  end

end

