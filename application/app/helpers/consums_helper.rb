module ConsumsHelper

  def render_menu
    if current_page?(:controller=>'platform_admin', :action=>'index')
      render :partial=> 'shared/controll_panel_head'
    else
      render :partial=> 'platform_admin/platform_header'  
    end
  end

end
