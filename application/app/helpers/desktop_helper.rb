module DesktopHelper
  def start_menu(menuid)
    '<div id="' + menuid + '" style="z-index:2;position:absolute;top:20px;left:auto;display:none;">'
  end
 
  def end_menu
    '</div>'
  end

  def show_user_list
    users = session[:user].group.users.reject{|u| u.status != 'active'}
    s = '<ul class="menu" style="font-size: 0.9em; font-weight: normal">'
    last = users.last
    users.each do |u|
      style = ' style="text-align: left;'
      style << ((u == last) ? 'border-bottom: 0px;">' : '">')
      online = (!Session.find_by_login(u.login).nil? ? '<span style="color: #51ff00;">' + t("online") + '</span>' : '<span style="color:#ff1e00;">' + t("offline") + '</span>')
      name = truncate(h(u.name) + ' ' + h(u.surname), {:length => 15, :omission => "..."})
      s << '<li' + style + name + ': ' + online + '</li>'
    end
    s << '</ul>'
  end

  def link_to_app(text, url, id)
     # la url tiene que ser https si estamos en SSL
     url = url.gsub(/^http:/,"https:") if request.ssl?
     link_to_function text, "addLayer('#{url}','#{id}'); addButton('#{text}','#{id}'); showApp('#{id}');", :id => "#{id}_link"
  end

end
