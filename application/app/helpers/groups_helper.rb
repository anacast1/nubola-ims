module GroupsHelper

  def render_menu
    if current_page?(:controller=>'root_admin', :action=>'index')
      render :partial=> 'shared/controll_panel_head'
    else
      render :partial=> 'root_admin/root_header'  
    end
  end

  def client_column(record)
    if record.client?
      return '<b class="green">' + I18n.t("activerecord.attributes.group.client") + '</b>'
    else
      return I18n.t("activerecord.attributes.group.demo_ends") +  ": #{record.demo_ends.strftime '%d/%m/%Y'}"
    end
  end

  def demo_ends_form_column(record, input_name)
    if record.client?
      "<p>never</p>"
    else
      date_select :record, :demo_ends, :name => input_name
    end
  end

  def active_column(record)
    if record.active?
      return I18n.t("say_yes") 
    else
      return ('<b class="red">' + I18n.t("say_no") + '</b>')
    end
  end

  def country_form_column(record, input_name)
    country_select(:record, :country, {I18n.t("countries.spain") => "spain"})
  end

  def country_column(record)
    I18n.t("countries.#{record.country}") unless record.country.blank?
  end

  def created_at_column(record)
    record.created_at.strftime '%d/%m/%Y' # to avoid showing hours
  end

  def available_academies
    App.find_all_by_is_academy(true).collect{|app| [app.name, app.unique_app_id]}
  end

end
