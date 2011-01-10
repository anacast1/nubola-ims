module ReportsHelper

  def render_menu
    if current_page?(:controller=>'reports', :action => 'admin_reports')
      render :partial => 'root_admin/root_header'
    else
      render :partial => 'reports/user_reports_header'  
    end
  end

  def mes_i_any(date)
    mesos = ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'] 
    t(mesos[date.month - 1]) + "/" + date.strftime("%Y")
  end

  # Lo normal es que torni a {:controller => 'ims'}, com el
  # helper general volver de application_helper. Pero en el
  # cas de reports si estem a dins d'un report tornara a 
  # l'index de reports
  def volver(help = nil, link=t("back"))
    desti = {:controller => 'ims'}
    unless (current_page?(:action => "user_reports") or current_page?(:action => "admin_reports"))
      desti = {:action => :index}
      help = t("back_to_reports_index") 
    end

    link_to link, desti, :title => help || t("back_to_control_panel")
  end

end
