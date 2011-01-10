class AlbaranesController < ApplicationController

  layout 'base'
  before_filter :login_required
  before_filter :authorize

  DIA_GENERACION_ALBARANES = 10
  COLS = [ :group, :concept_type, :period_from, :price, :quantity]

  active_scaffold :charges do |config|
    config.label = "albarans"
    config.columns[:group].label = "group"
    config.columns[:concept_type].label = "concept"
    config.columns[:period_from].label = "date"
    config.columns[:price].label = "price"
    config.columns[:quantity].label = "amount"
    config.list.columns = COLS
    config.list.sorting = { :created_at => :desc }
    config.list.per_page = 50
    config.columns["group"].clear_link
    config.actions = [ :list ]
  end
  
  private
  
  def conditions_for_collection
    ['group_id = ?', session[:user].group.id]
  end

  def authorize
    unless session[:user].groupadmin? or session[:user].root?
      flash[:notice] = I18n.t("invalid_login")
      redirect_to :controller => "ims"
    end
  end
 
end
