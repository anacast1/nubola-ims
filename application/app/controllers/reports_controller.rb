class ReportsController < ApplicationController

  layout "base"
  require "date"

  # FILTERS ------------------------------

  before_filter :login_required
  before_filter :set_user

  # Custom filters (implemented in this controller).

  # Functions that retrieve data for building graphs must all be after a filter
  # that only allows them to retrieve data from that users' group if the user
  # is not 'admin' or 'root'. 
  before_filter :check_selected_group_is_users_group, :only => [:usage_data_per_hour, :usage_data_per_day, :usage_per_hour, :usage_per_day]

  # Functions that show graphs must all be after a filter that only allows them
  # call the functions that collect data for a valid group.
  before_filter :check_group_exists, :only => [:usage_per_hour, :usage_per_day]


  # General filters (implemented in controllers/application.rb).

  # Only admin roles ('admin' or 'root') can access reports index.
  before_filter :check_is_root_or_admin, :only => :admin_reports

  # To see a group reports the user must have role 'group_admin'.
  # The 'check_selected_group_is_users_group' makes sure the selected group
  # is the users' group.
  before_filter :check_is_group_admin, :only => :user_reports


  # -------------------------------------


  # ACTIONS -----------------------------

  # Redirects to 'admin_reports' (for 'root' and 'admin' roles)
  # or to 'user_reports' (fot 'group_admin' role).
  def index
    redirect_to :action => 'admin_reports' and return if @user.root?
    redirect_to :action => 'user_reports' and return if @user.groupadmin?
    redirect_to :controller => 'sso'
  end

  def admin_reports
    if request.post?
      @group = Group.find_by_id params[:id]
      @group_id = params[:id]
    end
    @dates = []
    date = (Registre.find :first, :order => "created_at").created_at.beginning_of_month rescue Time.now
    while ( date <= Time.now )
      @dates << date
      date = date.next_month
    end
    @groups = Group.find :all, :order => "name"
  end

  # ajax
  def group_reports
    if params[:group].blank?
       redirect_to 'admin_reports'
	  else
	    @group = Group.find params[:group]
      @dates = []
      date = @group.created_at.beginning_of_month
      while ( (date <=> Time.now) < 1 )
        @dates << date
        date = date.next_month
      end
      render :partial => 'group_reports', :layout => false
	  end
  end

  def user_reports
    @group = session[:user].group
    @dates = []
    date = @group.created_at.beginning_of_month
    while ( (date <=> Time.now) < 1 )
      @dates << date
      date = date.next_month
    end
  end

  # open_flash_chart_object(width, height, url, use_swfobject=true, base='../', set_wmode_transparent=false)

  def usage_per_day
    @graph = open_flash_chart_object(600,300, "usage_data_per_day/#{params[:id]}?day=#{params[:day]}" + locale, false, "../", false)
    render :action => 'show_graph'
  end

  def usage_per_hour
    @graph = open_flash_chart_object(600,300, "../usage_data_per_hour/#{params[:id]}?day=#{params[:day]}" + locale, false, "../../", false)
    render :action => 'show_graph'
  end

  def concurrency_per_day
    @graph = open_flash_chart_object(600,300, "concurrency_data_per_day/#{params[:id]}?day=#{params[:day]}" + locale, false, "../", false)
    render :action => 'show_graph'
  end

  def concurrency_per_hour
    @graph = open_flash_chart_object(600,300, "../concurrency_data_per_hour/#{params[:id]}?day=#{params[:day]}" + locale, false, "../../", false)
    render :action => 'show_graph'
  end

  def usedspace_per_day
    @graph = open_flash_chart_object(600,300, "usedspace_data_per_day/#{params[:id]}?day=#{params[:day]}" + locale, false, "../", false)
    render :action => 'show_graph'
  end

  def installed_apps
    @graph = open_flash_chart_object(600,300, "installed_apps_data/#{params[:id]}?host=#{params[:host]}" + locale, false, "../", false)
    render :action => 'show_graph'
  end

  def all_graphs
    @graphs = []
    ["usage_data_per_day", "concurrency_data_per_day", "usedspace_data_per_day"].each do |method|
      @graphs << open_flash_chart_object(600,300, "#{method}/#{params[:id]}?day=#{params[:day]}" + locale, false, "../", false)
    end
    if session[:user].root? and params[:id] == "-1"
      @graphs << open_flash_chart_object(600,300, "installed_apps_data?host=all" + locale, false, "../", false)
    end
    render :action => 'show_graph'
  end

  # DATA FUNCTIONS -----------------------

  # Functions called by open_flash_chart swf objects to 
  # build the reports.
  # Make sure all of these functions are placed after
  # the 'check_selected_group_is_users_group' filter.

  HOUR = 60 * 60
  DAY  = HOUR * 24 

  def usage_data_per_day
    group = get_group(params[:id])
    day = Time.at params[:day].to_i
    this_month_first_day = day.beginning_of_month
    this_month_last_day  = day.end_of_month

    # initialize(alpha, color, outline_color)
    bar = BarOutline.new(50, '#9933CC', '#8010A0')
    # key(key, size)
    bar.key(I18n.t("number_of_connected_users_per_day"), 10)

    labels = []
    max_users = 0

    d = this_month_first_day
    while d < this_month_last_day
      today    = d
      tomorrow = d + 1.day
      logins = group.users_logged_in(today,tomorrow)
      max_users = logins if logins > max_users
      bar.add_link logins, "#{full_path}/reports/usage_per_hour/#{group.id}?day=#{today.to_i}" + locale
      labels << d.strftime("%d")
      d += 1.day
    end

    title = "#{group.name}: #{t("platform_usage")} (#{day.strftime('%m/%y')})"
    y_legend = t("connected_users")
    render :text => build_graph(bar,title,max_users + 1,y_legend,labels).render
  end

  def usage_data_per_hour
    group = get_group(params[:id])
    day = Time.at params[:day].to_i

    # initialize(alpha, color, outline_color)
    bar = BarOutline.new(50, '#9933CC', '#8010A0')
    # key(key, size)
    bar.key(t("number_of_connected_users_per_hour"), 10)

    labels = []
    max_users = 0

    eod = day.end_of_day
    d = day.beginning_of_day
    while d < eod
      from  = d
      to    = d + 1.hour - 1.second
      logins = group.users_logged_in(from,to)
      max_users = logins if logins > max_users
      bar.add logins
      labels << d.strftime("%H:%M")
      d += 1.hour
    end

    title = "#{group.name}: #{t("platform_usage")} (#{day.strftime('%d/%m/%y')})"
    y_legend = t("connected_users")
    render :text => build_graph(bar,title,max_users + 1,y_legend,labels).render
  end

  def concurrency_data_per_day
    group = get_group(params[:id])
    day = Time.at params[:day].to_i
    this_month_first_day = day.beginning_of_month
    this_month_last_day  = day.end_of_month

    # initialize(alpha, color, outline_color)
    bar = BarOutline.new(50, '#9933CC', '#8010A0')
    # key(key, size)
    bar.key(t("number_of_simultanously_connected_users_per_day"), 10)

    labels = []
    max_concurrency = 0
    last_period_connected_users = []

    d = this_month_first_day
    while d < this_month_last_day
      today    = d
      tomorrow = d + 1.day
      concurrency,last_period_connected_users = group.concurrency(today,tomorrow,last_period_connected_users)
      max_concurrency = concurrency if concurrency > max_concurrency
      if today < Time.now
        bar.add_link concurrency, "#{full_path}/reports/concurrency_per_hour/#{group.id}?day=#{today.to_i}" + locale
      else
        bar.add 0
      end
      labels << d.strftime("%d")
      d += 1.day
    end

    title = "#{group.name}: #{t("number_of_simultanously_connected_users")} (#{day.strftime('%m/%y')})"
    y_legend = t("users")
    render :text => build_graph(bar,title,max_concurrency + 1,y_legend,labels).render
  end

  def concurrency_data_per_hour
    group = get_group(params[:id])
    day = Time.at params[:day].to_i

    # initialize(alpha, color, outline_color)
    bar = BarOutline.new(50, '#9933CC', '#8010A0')
    # key(key, size)
    bar.key(t("number_of_simultanously_connected_users_per_hour"), 10)

    labels = []
    max_concurrency = 0
    last_period_connected_users = []

    from = day.beginning_of_day
    while from < day.end_of_day
      from_early=day.beginning_of_month
      to = from + 1.hour - 1.second
      concurrency,last_period_connected_users = group.concurrency(from,to,last_period_connected_users,from_early)
      max_concurrency = concurrency if concurrency > max_concurrency
      if from < Time.now
        bar.add concurrency
      else
        bar.add 0
      end
      labels << from.strftime("%H:%M")
      from += 1.hour
      from_early = nil
    end

    title = "#{group.name}: #{t("number_of_simultanously_connected_users")} (#{day.strftime('%d/%m/%y')})"
    y_legend = t("users")
    render :text => build_graph(bar,title,max_concurrency + 1,y_legend,labels).render
  end

  def usedspace_data_per_day
    group = get_group(params[:id])
    day = Time.at params[:day].to_i
    this_month_first_day = day.beginning_of_month
    this_month_last_day  = day.end_of_month

    # report es un hash de l'estil { Time => { app.id => amount }  }
    report = group.max_space(this_month_first_day,this_month_last_day,true)
    apps = report.collect { |k,v| v.collect { |k,v| k } }.flatten.compact.uniq

    colors = ["#0066CC","#9933CC","#639F45","#2211CC","#AA2211","#853326"]
    # creem un hash de l'estil: { app_id => Bar }
    bars = {}
    i=0 ; apps.each do |app_id|
      i = 0 if colors.size <= i
      app = App.find app_id
      bars[app.id] = Bar.new(50, colors[i])
      bars[app.id].key(app.name, 10)
    i+=1 ; end

    # recorrem el hash de manera ordenada i afegim els valors a les barres.
    report.keys.sort.each do |t|
      report[t].each do |app,amount|
        bars[app].data << amount
      end
    end

    g = Graph.new
    g.title("#{group.name}: #{t("space_used_by_applications")} (#{day.strftime('%m/%y')})", "{font-size: 15px;}")

    max_values = []
    bars.values.each do |b|
      g.data_sets << b
      max_values << b.data.max
    end
    max_value = max_values.max

    g.set_x_labels(report.keys.sort.collect {|t| (Time.at t).strftime("%d")})
    g.set_x_label_style(10, '#9933CC', 0, 2)
    g.set_x_axis_steps(2)
    g.set_y_max(max_value || 10)
    g.set_y_label_steps(2)
    g.set_y_legend(t("space_in_MB"), 12, "0x736AFF")
    render :text => g.render
  end

  def installed_apps_data
    case params[:host]
    when "shared"
      installs = Install.find(:all, :conditions => ["host_id = ?",Host.compartido.id])
      host = t("the_shared_host")
    when "virtual"
      installs = Install.find(:all, :conditions => ["host_id != ?",Host.compartido.id])
      host = t("the_particular_hosts")
    when "all"
      installs = Install.find(:all)
      host = t("all_hosts")
    end
    installs.reject!{ |i| i.app.is_academy }
    data = {}
    installs.each do |install|
      app = install.app.name
      data[app] = data[app].nil? ? 1 : data[app] + 1
    end

    g = Graph.new
    g.pie(60, '#505050', '{font-size: 12px; color: #404040;}')
    g.pie_values(data.values, data.keys)
    g.pie_slice_colors(%w(#d01fc3 #356aa0 #c79810))
    g.set_tool_tip("#val#")
    g.title("Aplicaciones Instaladas en #{host}", '{font-size:18px; color: #d01f3c}' )
    render :text => g.render
  end

  # --------------------------------------

  protected

  def check_selected_group_is_users_group
    roles = @user.role.split(" ")
    unless ( roles.include?("platformadmin") or roles.include?("privilegeduser") )
      if params[:id].to_i != @user.group.id
        flash[:error] = "Grupo inválido"
        redirect_to :controller => :ims
      end
    end
  end

  def check_group_exists
    return if params[:id] == "-1"
# s'utilitza?    return if params[:logins_graph] == "all"
    group = Group.find_by_id(params[:id])
    if group.nil?
      flash[:error] = "Grupo inválido"
      redirect_to :controller => :ims
      return
    end
  end

  def get_group(group)
    if group.to_i == -1 and ( @user.role.split(" ").include?("platformadmin") or @user.role.split(" ").include?("privilegeduser") )
      group = Group.new
      group.id = -1
      group.name = "Todos los grupos"
    else
      group = Group.find_by_id group
    end
    return group
  end

  def build_graph(data,title,y_max,y_legend,labels)
    g = Graph.new
    g.title( title, "{font-size: 15px;}" )
    g.data_sets << data
    g.set_x_labels( labels )
    g.set_x_label_style(10, '#9933CC', 0,2)
    g.set_x_axis_steps(1)
    g.set_y_max(y_max)
    g.set_y_label_steps(y_max)
    g.set_y_legend(y_legend, 12, "#736AFF")
    return g
  end

  def set_user
    @user = session[:user]
  end

  # Perque el open-flash-chart tingui enllaços que funcionin
  # tant de d'un mongrel/webrick a seques com des de darrera un
  # httpd on els enllaços tenen per davant algun path extra
  # (com per exemple /oap/ims), creem aqeusta funció que retorna
  # urls absolutes (amb path extra o no) a les que adjuntar
  # la ruta "intra-ims" desitjada.
  def full_path
    request.url.split("/reports").first
  end

  def locale
    "&locale=#{I18n.locale}"
  end
end
