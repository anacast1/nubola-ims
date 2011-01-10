module AppsHelper

  def render_menu
    if current_page?(:controller=>'root_admin', :action=>'index')
      render :partial=> 'shared/controll_panel_head'
    else
      render :partial=> 'root_admin/root_header'  
    end
  end

  def logo_image_column(record)
    image_tag(url_for_file_column(record, :logo_image), :border => 0)  if record.logo_image
  end

end
