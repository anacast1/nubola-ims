module RootAdminHelper
  
  def render_menu
    if current_page?(:controller=>'root_admin', :action=>'index')
      render :partial=> 'shared/controll_panel_head'
    else
      render :partial=> 'root_admin/root_header'  
    end
  end

end
