module ContractsHelper

  # Pel cas del group_admin es tria la header a group_admin_helper, 
  # ja que els grpoupadmins arriben a contractes arriba des d'aquell 
  # controller
  def render_menu
    if current_page?(:controller=>'root_admin', :action=>'index')
      render :partial=> 'shared/controll_panel_head'
    else
      render :partial=> 'root_admin/root_header'  
    end
  end

  def checked?(what,which)
    @record.send(what).include?(which) ? "checked=\"checked\"" : ""
  end

  def susp_rest?(state)
    return "Suspender"   if state == 1
    return "Restablecer" if state == 0
    return ""
  end

  def group_column(record)
    return record.group.name rescue ""
  end

  def co_country_form_column(record, input_name)
    country_select(:record, :co_country, {I18n.t("countries.spain") => "spain"})
  end

  def co_country_column(record)
    I18n.t("countries.#{record.co_country}") unless record.co_country.blank?
  end

end
