module ApplicationHelper

  def continuar
    volver t("go_to_control_panel"), t("continue")
  end
  
  def volver(help=nil,link=t("back"))
    link_to link, {:controller => 'ims'}, :title => help || t("back_to_control_panel")
  end

  def standalone_logout
    link_to " Logout", :controller=>'sso', :action=>'logout' if Setting.standalone
  end
  
  def user_image(user)
    if user && user.user_image
      path = url_for_file_column(user, "user_image")
    else
      path = 'default_user.png'
    end
    image_tag path, :border => "0", :title => h(user.name) + " " + h(user.surname)
  end

  # Posem aquesta funció aquí perquè es crida tant des de
  # group_admin_controller com des de reports_controller
  def state_column(record)
    if record.state == 0
      return "Suspendido"
    elsif record.state == 1
      return "Activo"
    else
      return "Borrado"
    end
  end 
   
  # In strings that are going to be shown as a
  # desktop button (i.e "control_panel"), blanks are written
  # in config/locales files as "&nbsp;" so the full string is
  # shown in the button. If we need to put the string
  # elsewhere, we use this to avoid showing "&nbsp;" escaped.
  def nbsp_to_space(str)
    str.gsub("&nbsp;", " ")
  end
  
  # Convert a string in UTF-8 to ISO-8859-15.
  # Useful in views that need to be converted to
  # pdf with HTMLDOC, that doesn't support UTF-8 yet
  def iso(string)
    converter = Iconv.new('ISO-8859-15','UTF-8')
    converter.iconv(string)
  end
  
  
  def help_tag(text)
    r =  '<div>'  
    r << '  <div id="help_first" class="vtopright">'
    r <<      link_to_function(t("help"), :onclick => "Element.hide('help_first'); Element.show('help_second');")
    r << '  </div>'
    
    r << '  <div id="help_second" class="help" style="display: none;">'
    r << '    <div class="vtopright" style="float: right;">' + link_to_function(t("hide"), :onclick => "Element.hide('help_second'); Element.show('help_first');") + '</div>'
    r <<      text
    r << '  </div>'
    r << '</div>'
  end
  
  # Usage: 
  #  header_tag(:image => "apps.png", :title => t("apps"),
  #             :top_buttons => [{:content => "bla bla", :active => false},{...},...],
  #             :bottom_buttons => [{:content => "bla bla bla", :active => true},...]
  def header_tag(options = {}) 
    options[:top_buttons] = options[:top_buttons].nil? ? [] : options[:top_buttons]
    options[:bottom_buttons] = options[:bottom_buttons].nil? ? [] : options[:bottom_buttons]
    
    r = '<div class="header"><div class="bl"><div class="br"><div class="tr"><div class="tl" style="height: 80px;">'
    
    r << '<div class="header_buttons">'
    
      r << '<div class="header_top_buttons">'
        options[:top_buttons].each do |b|
          r << header_btn_tag(:content => b[:content])
        end
      r << '</div>'
    
      r << '<div class="header_bottom_buttons">'
        options[:bottom_buttons].each do |b|
          r << header_btn_tag(:content => b[:content], :active => b[:active]) 
        end
      r << '</div>'
      
      r << '<div class="header_caption">'
        unless options[:image].nil?
          if options[:image] =~ /img/
            r << options[:image]
          else  
            r << image_tag(options[:image], :class => 'header_image')
          end
        end  
        r << '<span class="header_title">' + options[:title] + '</span>' if options[:title]
      r << '</div>'
      
    r << '</div>'
    
    r << '</div></div></div></div></div>'
  end
  
  def header_btn_tag(options = {})
    content = options[:content]
    active = [true, false].include?(options[:active]) ? options[:active] : false
    
    content_klass = ""
    if active
      content_klass = "btn_content btn_active"
    else
      content_klass = "btn_content btn_inactive"
    end  
    
    r = '<div class="header_button">'
      r << '<div class="' + content_klass + '">' + content + '</div>'
    r << '</div>'
  end
  
  def ok_tag content
    r = ""
    unless content.nil?
      r << '<div class="ok">' + content + '</div>'
    end
    r
  end
  
  def warn_tag content
    r = ""
    unless content.nil?
      r << '<div class="warn">' + content + '</div>'
    end
    r
  end
  
  def info_tag content
    r = ""
    unless content.nil?
      r << '<div class="info">' + content + '</div>'
    end
    r
  end
  
  # label helper to show "label-value" list of a record
  # (like when showing record info for a user, group, contract...)
  def label_tag(label)
    label = "" if label.blank?
    '<tr><td class="label">' +  label + ':</td>'
  end
  
  # value helper to show "label-value" list of a record
  # (like when showing record info for a user, group, contract...)
  def value_tag(value)
    value = "" if value.blank?
    '<td class="value">' + value + '</td></tr>'
  end
  
end
