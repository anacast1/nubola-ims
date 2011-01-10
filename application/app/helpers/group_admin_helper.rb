module GroupAdminHelper

  def render_menu
    if current_page?(:controller=>'group_admin', :action=>'index')
      render :partial=> 'shared/controll_panel_head'
    elsif current_page?(:controller=>'group_admin', :action=>'contract')
      render :partial=> 'group_admin/contract_header'
    elsif current_page?(:controller=>'group_admin', :action=>'new_contract')
      render :partial=> 'group_admin/contract_header'
    elsif current_page?(:controller=>'group_admin', :action=>'edit_contract')
      render :partial=> 'group_admin/contract_header'
    else
      # TODO: difícil factor comú ...
    end
  end

  def info_app(app,group)
    unless group.apps.include? app
      return "#{t("say_no")} "
    end
    if group.installs.find_by_app_id(app).host.compartido?
      return "#{t("say_yes")} (#{t("shared_host")})"
    end
    return "#{t("say_yes")} (#{t("particular_server")})"
  end

  def requisitos_app(app)
    return "#{app.cpu} MHz #{t("vhost_cpu")}, #{app.basesize} MB #{t("vhost_disk")}, #{app.ram} MB #{t("vhost_ram")}"
  end

  # Lo normal es que torni a {:controller => 'ims'}, com el
  # helper general volver de application_helper. Pero en el
  # cas de contractes si estem a editant contracte tornara a 
  # l'index del contracte
  def volver(help = nil, link=t(:back))
    desti = {:controller => 'ims'}
    if (current_page?(:action => "edit_contract"))
      desti = {:action => :contract}
      help = t("back_to_contract") 
    end

    link_to link, desti, :title => help || t("back_to_control_panel")
  end

  def contr_sep(title)
    r = ''
    r << '<tr class="contr_section">'
    r << '<td colspan="2"><b>' + title + '</b></td>'
    r << '</tr>'
  end
  
  # Ex:
  #   edit_unless_client(contract, :name, :style => "color: black;", :maxlength => 5)
  #     => <td style="color: black;"><input type="text" size=5 maxlength=5/></td> (not client)
  #     => <td class)"value">some_text</td>" (client)
  def edit_unless_client(contract, field, *options)
    options = options.first.nil? ? Hash.new : options.first
    style = options[:style].blank? ? "" : options[:style]
    h = {:size => 30}
    if options[:maxlength]
      h[:size] = [h[:size], options[:maxlength]].min
      h.merge(:maxlength => options[:maxlength])
    end
    
    r = ''
    if session[:user].group.client?
      r << '<td class="value">' + h(contract.send(field)) + '</td>'
    else
      r << "<td class=\"value\" #{!style.blank? ? "style=\"" + style + "\";" : ""} >" + text_field(:contract, field, h) + "</td>"
    end
    r
  end
  
  def pdf_image_tag(image, options = {})
    options[:src] = File.expand_path(RAILS_ROOT) + '/public/images/' + image 
    tag(:img, options)
  end

end
