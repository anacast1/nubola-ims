require 'htmldoc'

class GroupAdminController < ApplicationController
  layout 'base'
  before_filter :login_required
  before_filter :authorize

  def index
    @control_panel_menu = Setting.admin_control_panel_menu
    # no mostrar "SERVIDOR PARTICULAR" al menu si el grup no es client o no estan habilitats
    particular_hosts = Setting.particular_hosts rescue "disabled"
    unless (session[:user].group.client?  and particular_hosts == "enabled")
      position = (@control_panel_menu.collect { |menu_elem| menu_elem["name"] }).index("particular_server")
      @control_panel_menu.delete_at position unless position.nil? # a production pot ser nil
    end
    render :template => "shared/controll_panel"
  end  

  # GROUP MANAGMENT

  def group_index
    @group = Group.find(session[:user].group_id)
  end

  def group_settings

    @group = Group.find(session[:user].group_id)

    if request.post?

      if params[:modify]
        if @group.update_attributes(params[:group])

          user = @group.users.select{ |u| u.role=="groupadmin"}.first
          message = user.adduser_message [], true # this includes GENERAL
          unless system("#{Setting.oappublish} 'IMS' '#{message}'")
            logger.info("Problem publishing adduser message")
          end

          # TODO: SEND AN INSTALL MESSAGE TO ALL GROUP INSTALLED APPLICATIONS
          flash[:group_saved] = I18n.t("group") + " " + I18n.t("modifyied")
          redirect_to :action => 'group_index'
        end
      end

      if params[:cancel]
        redirect_to :action => "group_index"
      end

    end
  end

  # USERS MANAGMENT

  def user_list
    @users = User.find_all_by_group_id_and_role(session[:user].group_id, 'groupadmin')
    @users += User.find_all_by_group_id_and_role(session[:user].group_id, 'user', :order => "name")
  end

  def user_index
    @user = User.find params[:id]
  end

  def user_install
    @user = User.find params[:id]
    if request.post?
      unless @user.status == 'inactive'
        redirect_to :action => 'index'
        return
      end

      @user.password = @user.password_confirmation = @user.plain_password
      @user.update_attributes(:status => 'active')

      message = @user.adduser_message [], true # this includes GENERAL
      unless system("#{Setting.oappublish} 'IMS' '#{message}'")
        logger.info("Problem publishing adduser message")
      end

      flash[:installed] = t("user") + " " + t("activated").downcase + "."
      redirect_to :action => 'user_uninstall', :id => @user
    end
  end

  def user_settings
    @user = User.find params[:id]
    if request.get?
      @user.password = nil
    elsif request.post?
      if @user.status == 'inactive'
        redirect_to :action => 'user_index'
      end
      if params[:modify]
        if @user.update_attributes(params[:user])
          # send an adduser message to each user application
          apps_to_be_added_to = Array.new
          @user.apps.each do |a|
            # if the application has as a parameter some kind of 
            # password transformation, also include it in this
            # adduser message in case it has changed
            parameters_hash = {} # format is: {pid => pvalue}
            pw_param =  a.parameters.find_by_name "password"
            unless pw_param.nil?
              parameters_hash[pw_param.id] = @user.send(pw_param.default_value.split(".").last.to_sym)
            end
            apps_to_be_added_to << {:application => a, :parameters => parameters_hash}
          end
          message = @user.adduser_message apps_to_be_added_to, true # this includes GENERAL
          unless system("#{Setting.oappublish} 'IMS' '#{message}'")
            logger.info("Problem publishing adduser message")
          end

          flash[:user_modified] = t("user") + " " + t("modifyied") + "."

          redirect_to :action => 'user_index', :id => @user
        end
        @user.password = @user.password_confirmation = nil
      elsif params[:cancel]
        redirect_to :action => 'user_index', :id => @user
      elsif params[:default_image]
        @user.password = @user.password_confirmation = ""
        @user.update_attributes(:user_image => nil)
        @user.password = @user.password_confirmation = nil
      end
    end
  end

  def user_new
    if request.get?
      @user = User.new
    elsif request.post?
      if params[:new_user]
        @user = User.new(params[:user])
        @user.role = "user"
        @user.group_id = session[:user].group_id
        @user.confirmed = true;
        if @user.save
          message = @user.adduser_message [], true # this includes GENERAL
          unless system("#{Setting.oappublish} 'IMS' '#{message}'")
            logger.info("Problem publishing adduser message")
          end
          flash[:user_created] = t("user") + " " + t("created") + "."
          
          redirect_to :action => "user_list"
        end
      elsif params[:cancel]
        redirect_to :action => "user_list"
      end
    end
  end

  def user_bind_apps
    @user = User.find params[:id]
    group = Group.find session[:user].group.id
    installs = group.installs.reject{|i| !i.ready? or !i.app.admin_user_available? or !i.app.has_users}
    @apps = installs.map{|i| i.app}
  end

  def user_uninstall
    @user = User.find params[:id]
    if request.post? && @user != session[:user]
      if @user.status == 'inactive'
        redirect_to :action => 'index'
        return
      end
      # send a deluser message with the applications
      # the user is assigned to
      apps_to_be_deleted_from = Array.new
      @user.apps.each do |a|
        apps_to_be_deleted_from << a
        
        # # unbind user from app
        # a.users.delete @user
        
        # delete user settings for the user and app
        a.parameters.each do |p|
          us = UserSetting.find_by_user_id_and_parameter_id(@user.id, p.id)
          us.destroy unless us.nil?
        end
      end
      
      message = @user.deluser_message apps_to_be_deleted_from, true # this includes GENERAL
      unless system("#{Setting.oappublish} 'IMS' '#{message}'")
        logger.info("Problem publishing deluser message")
      end

      # TODO: THINK IF WE MUST WAIT DELUSER MESSAGE RESPONSE FROM EACH APPLICATION

      @user.password = @user.password_confirmation = @user.plain_password
      @user.update_attributes(:status => 'inactive')

      flash[:uninstalled] = t("user") +  " " + t("deactivated").downcase + "."
      redirect_to :action => 'user_install', :id => @user
    end
  end

  # APPLICATIONS MANAGMENT

  def app_list

    # perque es marqui la pestanya de disponibles
    if params[:apps] == nil
      params[:apps] = "available"
    end

    if params[:apps] == "installed"
      @apps =  User.find(session[:user].id).group.apps.find_all_by_admin_user_available(true)
    elsif params[:apps] == "uninstalled"
      @apps =  User.find(session[:user].id).group.apps.find_all_by_admin_user_available(false)
    else
      @apps = App.find_all_by_admin_user_available_and_is_academy(true, false)
    end

  end

  def app_index
    set_app_vars
  end

  def app_install

    set_app_vars
   
    if @installed
      redirect_to :action => :app_edit, :id => @app
      return
    end

    if request.get?
      #check dependencies
      error=false;
      dep_str=""
      @app.dependencias.each do |ap|
        a=App.find_by_id(ap.id)
        if a.nil?
          error=true;
          dep_str=dep_str+ap.name+", "
        end
      end
      deps=dep_str[0..dep_str.size()-3]
      if error
        flash[:list] = "#{@app.name} #{t("depends_on")} #{deps}. #{install_deps_before}."
        render :action => 'app_dep_error', :id => @app 
      end
    end
    
    if request.post?

      # convert translated values to real ones
      if params[:group_parameters]!= nil

        # substitute group_parameters that start with Group.* by their real value
        params[:group_parameters].each_pair do |pid, pvalue|
          if pvalue.include?("Group.")
            field_name =  pvalue.split(".")[1]
            g = Group.find_by_sql("SELECT groups." + field_name + " FROM groups WHERE id = " +   session[:user].group.id.to_s)[0]
            params[:group_parameters].update({pid => g.attributes[field_name]})
          end
        end

      end

      if @app.clickgest?

        # clickgest no s'instala: https://www.ingent.net/issues/2357
        @install = Install.new
        @install.app = @app
        @install.group = @group
        @install.host = Host.compartido
        @install.status = "OK"
        @install.save
        bind = Bind.create!(:user_id => session[:user].id, :app_id => @app.id, :status => 'OK')
        session[:user].apps.reload
        redirect_to :action => 'app_edit', :id => @app

      else

        apps_to_install = Array.new
        if params[:group_parameters] != nil
          apps_to_install << {:application => @app, :parameters => params[:group_parameters]}
        else
          apps_to_install << {:application => @app, :parameters => {}}
        end

        # save this install before sending the message, because
        # we need it to process the response
        @install.host = Host.find_by_hostname params[:host_id]
        @install.status = "INSTALLING"
        @install.save!

        message = session[:user].group.install_message(apps_to_install, params[:host_id], params[:original_host])
        unless system("#{Setting.oappublish} 'IMS' '#{message}'")
          logger.info("Problem publishing install message")
        end

        # ens esperem uns segons perque amb una mica de sort la
        # resposta haurà arribat i ja podrem assignar usuaris
        # a la app (si no mostrarem un missatge de que la app
        # s'està instal.lant)
        may_sleep 8

        unless params[:group_parameters] == nil
          params[:group_parameters].each_pair do |pid, pvalue|
            # find the group_setting corresponding to the parameter for this group
            group_setting = GroupSetting.find_by_group_id_and_parameter_id(session[:user].group.id, pid)
            default_value = Parameter.find_by_id(pid).default_value
            if default_value.include?("Group.")
              # the parameter is a calculated one, so each time it can be modified. we don't store the result, we store the function name
              # if the group has the group_setting
              # (this should never happen here, since this is a first time installation)
              if group_setting
                # update that setting
                group_setting.update_attributes(:value => default_value)
                # else if the group hasn't a group_setting for the parameter
              else
                # create that setting
                group_setting = GroupSetting.new({:group_id => session[:user].group.id,
                                                 :parameter_id => pid,
                                                 :value => default_value})
                group_setting.save!
              end
            else
              if group_setting
                group_setting.update_attributes(:value => pvalue)
              else
                group_setting = GroupSetting.new({:group_id => session[:user].group.id,
                                                 :parameter_id => pid,
                                                 :value => pvalue})
                group_setting.save!
              end
            end
          end
        end
        session[:user].apps.reload
        redirect_to :action => 'app_bind_users', :id => @app
      end

    end
  end

  def app_bind_users
    set_app_vars

    unless @app.has_users and @install.ready?
      redirect_to :action => 'app_edit', :id => @app
      return
    end

    if @app.clickgest?
      render :template => 'group_admin/clickgest'
      return
    end

    @users = User.find_all_by_group_id_and_status session[:user].group.id, "active"

    if request.post?
      # find the user
      u = User.find params[:user_id]

      if params[:save_user_settings]
        # save user settings ( + adduser when parameters modified)

        params[:user_parameters] = {} if params[:user_parameters].nil?

        # keep only user_parameters that are different from current user settings
        params[:user_parameters].delete_if{|pid, pvalue|
          us = UserSetting.find_by_user_id_and_parameter_id(u.id, pid)
          result = false
          if us == nil or us.value != pvalue
            result = false
          elsif us.value == pvalue
            result =  true
          end
          result
        }

        # crear un bind entre user i app si es un nou bind;
        # es crea amb status = "BINDING", l'adaptador ja el 
        # posarà a "OK" quan rebi la resposta, i enviarà un 
        # missatge de login si l'usuari està loginat perquè
        # l'app deixi entrar l'usuari
        bind = Bind.find_by_user_id_and_app_id(u.id, @app.id)
        if bind.nil?
          bind = Bind.create!(:user_id => u.id, :app_id => @app.id, :status => 'BINDING')
        end

        # if there are changed user settings, generate adduser message
        if !params[:user_parameters].empty?
          apps_to_be_added_to = Array.new
          apps_to_be_added_to << {:application => @app, :parameters => params[:user_parameters]}
          message = u.adduser_message apps_to_be_added_to
          unless system("#{Setting.oappublish} 'IMS' '#{message}'")
            logger.info("Problem publishing adduser message")
          end

          may_sleep 8

        # if there aren't changed user settings, but the user is new
        # for the the application, we must still generate the message.
        elsif params[:user_parameters].empty?
          if bind.status == "BINDING"
            apps_to_be_added_to = Array.new
            apps_to_be_added_to << {:application => @app, :parameters => {}}
            message = u.adduser_message apps_to_be_added_to
            unless system("#{Setting.oappublish} 'IMS' '#{message}'")
              logger.info("Problem publishing adduser message")
            end

            may_sleep 8

          end

        end

        # save user_settings for the application.
        params[:user_parameters].each_pair do |pid, pvalue|
          # if the user has the user_setting corresponding to the parameter
          user_setting = UserSetting.find_by_user_id_and_parameter_id(u.id, pid)
          # find the group_setting corresponding to the parameter for this group
          default_value = Parameter.find_by_id(pid).default_value
          if default_value.include?("User.")
            if user_setting
              # update that setting
              user_setting.update_attributes(:value => default_value)
            # else if the user hasn't a user_setting for the parameter
            else
              # create that setting
              user_setting = UserSetting.new({:user_id => u.id,
                                              :parameter_id => pid,
                                              :value => default_value})
              user_setting.save!
            end
          else
            if user_setting
              # update that setting
              user_setting.update_attributes(:value => pvalue)
            # else if the user hasn't a user_setting for the parameter
            else
              # create that setting
              user_setting = UserSetting.new({:user_id => u.id,
                                              :parameter_id => pid,
                                              :value => pvalue})
              user_setting.save!
            end
          end
        end
       
        # no faria falta, però així amb una mica de sort quan 
        # l'usuari cliqui al menú d'aplicacions ja la veurà 
        # disponible (s'haurà rebut la resposta a l'adduser)  
        may_sleep 5

        flash[:binding_result] = "#{t("in_a_few_moments_the_user")} <b>#{h(u.name)} #{h(u.surname)}</b> #{t("will_have_access_to_app")} <b>#{@app.name}</b> #{t("from_his_menu")} <b>#{t("apps")}</b>."

      elsif params[:delete_user_settings]

        apps_to_be_deleted_from = Array.new
        apps_to_be_deleted_from << @app
        message = u.deluser_message apps_to_be_deleted_from
        unless system("#{Setting.oappublish} 'IMS' '#{message}'")
          logger.info("Problem publishing deluser message")
        end

        # unbind user from app
        bind = Bind.find_by_app_id_and_user_id(@app.id, u.id)
        bind.update_attributes!(:status => "UNBINDING")
        
        # delete user settings for the user and app
        @app.parameters.each do |p|
          us = UserSetting.find_by_user_id_and_parameter_id(u.id, p.id)
          us.destroy unless us.nil?
        end

        # no faria falta, però així amb sort quan 
        # acabi potser ja ha arribat la resposta
        may_sleep 5

        flash[:binding_result] = "#{t("access_to_app_removed_for_user")} <b>#{h(u.name)} #{h(u.surname)}</b> #{t("to_application")} <b>#{@app.name}</b>."
      end

      if params[:origin] == nil
        redirect_to :action => 'app_index'
      elsif params[:origin] == 'user_bind_apps'
        redirect_to :action => 'user_bind_apps', :id => u
      elsif params[:origin] == 'app_bind_users'
        redirect_to :action => 'app_bind_users', :id => @app
      end

    end
  end

  def app_settings
    set_app_vars
    unless @installed
      redirect_to :action => 'app_index', :id => @app
      return
    end
    if request.post?

      if params[:cancel]
        redirect_to :action => "app_index", :id => @app
        return
      end

      # generate install application message

      if params[:group_parameters] == nil
        params[:group_parameters] = {}
      end

      # substitute group_parameters that start with Group.* by their real value
      params[:group_parameters].each_pair do |pid, pvalue|
        if pvalue.include?("Group.")
          field_name =  pvalue.split(".")[1]
          g = Group.find_by_sql("SELECT groups." + field_name + " FROM groups WHERE id = " + session[:user].group.id.to_s)[0]
          params[:group_parameters].update({pid => g.attributes[field_name]})
        end
      end

      # keep only group_parameters that have changed
      params[:group_parameters].delete_if{|pid, pvalue|
        gs = GroupSetting.find_by_group_id_and_parameter_id(session[:user].group.id, pid)
        result = false
        if gs == nil or gs.value != pvalue
          result = false
        elsif gs.value == pvalue
          result = true
        end
        result
      }

      # if there are changed group_settings, generate install message
      if !params[:group_parameters].empty?
        apps_to_install = Array.new
        apps_to_install << {:application => @app, :parameters => params[:group_parameters]}
        message = session[:user].group.install_message(apps_to_install, @install.host.hostname, @install.host.hostname)
        unless system("#{Setting.oappublish} 'IMS' '#{message}'")
          logger.info("Problem publishing install message")
        end
        may_sleep 2
        #----------------------------------
        session[:user].send_logout_message(session.session_id)
        may_sleep 2
        session[:user].send_login_message(session.session_id)
        may_sleep 8
        #----------------------------------
      end

      params[:group_parameters].each_pair do |pid, pvalue|
        # find the group_setting corresponding to the parameter for this group
        group_setting = GroupSetting.find_by_group_id_and_parameter_id(session[:user].group.id, pid)
        default_value = Parameter.find_by_id(pid).default_value
        if default_value.include?("Group.")
          # the parameter is a calculated one, so each time it can be modified. we don't store the result, we store the function name
          # if the group has the group_setting
          if group_setting
            # update that setting
            group_setting.update_attributes(:value => default_value)
          # else if the group hasn't a group_setting for the parameter
          else
            # create that setting
            group_setting = GroupSetting.new({:group_id => session[:user].group.id,
                                              :parameter_id => pid,
                                              :value => default_value})
            group_setting.save!
          end
        else
          if group_setting
            group_setting.update_attributes(:value => pvalue)
          else
            group_setting = GroupSetting.new({:group_id => session[:user].group.id,
                                              :parameter_id => pid,
                                              :value => pvalue})
            group_setting.save!
          end
        end

        # find the group_setting corresponding to the parameter for this group
        group_setting = GroupSetting.find_by_group_id_and_parameter_id(session[:user].group.id, pid)
        # if the group has the group_setting
        if group_setting
          # update that setting
          group_setting.update_attributes(:value => pvalue)
        # else if the group hasn't a group_setting for the parameter
        else
          # create that setting
          group_setting = GroupSetting.new({:group_id => session[:user].group.id,
                                            :parameter_id => pid,
                                            :value => pvalue})
          group_setting.save!
        end
      end

      flash[:app_modified] = "#{t("group_settings_modified_for_app")} #{@app.name}."
      redirect_to :action => 'app_index', :id => @app

    end
  end

  def app_uninstall

    set_app_vars

    if request.post?
      #check dependencies
      error=false;
      dep_str=""
      @app.dependientes.each do |ap|
        a=applications.find_by_id(ap.id)
        if !a.nil?
          error=true;
          dep_str=dep_str+ap.name+", "
        end
      end
      deps=dep_str[0..dep_str.size()-3]
      if error
        flash[:list] = "#{t("the_following_apps_depend_on")} #{@app.name}: #{deps}. #{t("cannot_uninstall_until")}."
        render :action => 'app_dep_error', :id => @app 
        return
      end
    
      #application = App.find(params[:id])

      # search user/group settings for this application and if present delete them
      @app.parameters.each do |parameter|
        # delete from database group settings for this group and app
        if (parameter.kind == "group") or (parameter.kind == "global")
          gs = GroupSetting.find_by_group_id_and_parameter_id(session[:user].group.id, parameter.id)
          if gs
            gs.destroy
          end
        end
        # delete from database user settings for users in this group and app
        @app.users.each do |user|
          if (parameter.kind == "user") or (parameter.kind == "global")
            us = UserSetting.find_by_user_id_and_parameter_id(user.id, parameter.id)
            if us
              us.destroy
            end
          end
        end
      end

      # eliminem els binds dels usuaris del grup amb la aplicacio
      binds = []
      group = Group.find(session[:user].group.id)
      group.users.each do |u|
        b = u.binds.find_by_app_id(@app.id)
        binds << b unless b.nil?
      end
      binds.each do |b|
        b.destroy
      end

      if @app.clickgest?

        @install.destroy

      else

        # marquem l'install de la app com a "UNINSTALLING", xque no la puguin gestionar
        # mentre es desinstal.la
        @install.update_attributes!(:status => "UNINSTALLING")

        # enviem missatge uninstall
        apps_to_uninstall = Array.new
        apps_to_uninstall <<  @app
        message = session[:user].group.uninstall_message(apps_to_uninstall, @install.host.hostname)
        unless system("#{Setting.oappublish} 'IMS' '#{message}'")
          logger.info("Problem publishing uninstall message")
        end

        # amb sort la resposta ja haurà arribat
        may_sleep 5

      end

      flash[:uninstalled] = "#{t("uninstalling")} #{@app.name}.<br />#{t("once_uninstalled_will_be_available")}."
      redirect_to :action => 'app_install', :id => @app
    end
  end

  def app_edit
    set_app_vars

    unless @group.apps.include?(@app)
      redirect_to :action => 'app_index', :id => @app
      return
    end
    @dependent_apps = ""
    @app.dependientes.each do |ap|
      unless @group.apps.find_by_id(ap.id).nil?
        @dependent_apps += ap.name + ", "
      end
    end
    @dependent_apps.chop!.chop! if @dependent_apps.size > 2

  end

  def app_move
    set_app_vars
    unless @install.ready?
      redirect_to :action => 'app_edit', :id => @app
      return
    end

    if request.post?
      if params[:host_id] != @install.host_id
        @install.host = Host.find_by_hostname params[:host_id]
        @install.status = "MOVING"
        @install.save
        #TODO: parameters ???
        message = @group.install_message([{:application => @app, :parameters => {}}], params[:host_id], params[:original_host])
        unless system("#{Setting.oappublish} 'IMS' '#{message}'")
          logger.info("Problem publishing install message")
        end
        may_sleep 5
      end
    end

    flash[:edit] = "#{@app.name} #{t("app_moved_ok")}"
    redirect_to :action => 'app_edit', :id => @app
  end

#  no utilitzat de moment
#
#  def app_backup
#    @app = App.find params[:id]
#    group = Group.find session[:user].group.id
#    @installed = group.apps.include?(@app)
#    unless @installed
#      redirect_to :action => 'app_index', :id => @app
#      return
#    end
#    group = Group.find session[:user].group.id
#    if request.post?
#      apps_to_backup = Array.new
#      apps_to_backup << {:application => @app}
#      message = session[:user].group.backup_message(apps_to_backup, session[:user])
#      unless system("#{Setting.oappublish} 'IMS' '#{message}'")
#        logger.info("Problem publishing backup message")
#      end
#      may_sleep 2
#      flash[:uninstalled] = "Se ha realizado la copia de seguridad de #{@app.name}."
#      redirect_to :action => 'app_index', :id => @app
#    end
#  end

  # VIRTUAL HOST MANAGEMENT

  def vhost
    @group = session[:user].group
    @vhost = @group.vhost
    redirect_to :action => 'vhost_install' if @vhost.nil?
  end

  def vhost_install
    @group = session[:user].group
    @vhost = @group.vhost
    @host_types = HostType.vhost_types

    if request.post? and session[:user].group.client?
      if params[:host_type_id].nil?
        flash[:install] = t("must_choose_server_type")
        return
      end
      vhost = Host.new(params[:host])
      vhost.hostname = "#{@group.id}.#{Setting.shared_host.split(".")[1..-1].join(".")}"
      vhost.groups << @group
      vhost.status = "INSTALLING"
      vhost.host_type = HostType.find params[:host_type_id]
      if vhost.save # es fa al model: and system("#{Setting.oappublish} 'IMS' '#{vhost.addhost_message}'")
        flash[:vhost] = t("installing_particular_server")
        redirect_to :action => "vhost"
      else
        flash[:error] = "#{t("there_was_an_error")}<br />#{vhost.errors.full_messages}"
      end
    end
  end

  def vhost_edit
    @group = session[:user].group
    @vhost = @group.vhost
    @host_types = HostType.vhost_types

    if request.post? and session[:user].group.client?
      new_host_type = HostType.find params[:host_type_id]
      if @vhost.host_type > new_host_type
        flash[:error] = t("chosen_host_is_smaller") 
        return
      end
      return if new_host_type.id == @vhost.host_type.id
      @vhost.host_type = new_host_type
      @vhost.status = "MODIFYING"
      if @vhost.save # es fa al model: and system("#{Setting.oappublish} 'IMS' '#{@vhost.modifyhost_message}'")
        flash[:vhost] = t("updating_particular_server")
        redirect_to :action => "vhost"
      else
        flash[:error] = "#{t("there_was_an_error")}<br />#{@vhost.errors.full_messages}"
      end
    end
  end

  def vhost_simulate
    @group = session[:user].group
    @vhost = @group.vhost
    @installed_apps = @group.installs
    @apps = App.find_all_by_is_academy(false)
    @selected_apps = @group.apps
  end

  def vhost_delete
    if request.post? and session[:user].group.client?
      @vhost = Host.find params[:id]
      if @vhost.apps.size > 0
        flash[:vhost] = t("before_destroy_server_must_uninstall_apps")
        redirect_to :action => "vhost_edit"
        return
      end
      @vhost.status="DELETING"
      if @vhost.save # es fa al model: and system("#{Setting.oappublish} 'IMS' '#{@vhost.delhost_message}'")
        # forçat a mà, xque el destroy es fa al adaptor i no podem fer servir callbacks 
        @vhost.send_xml_for_destroy
        flash[:vhost] = t("deleting_particular_server")
        redirect_to :action => "vhost"
      else
        flash[:error] = "#{t("there_was_an_error")}<br />#{@vhost.errors.full_messages}"
      end
    end
  end

  def do_simulation
    @host_types = HostType.vhost_types
    @group = session[:user].group
    @apps = App.find_all_by_is_academy(false)
    @selected_apps = []
    params['apps'].each do |app|
      @selected_apps << App.find(app[0]) if app[1] == "1"
    end
    @recomended_vhost,@ram,@cpu,@disk = HostType.required_host_type(@selected_apps)
    render :partial => 'simulation_results'
  end

  # CONTRACTS

  def contract
    @user = session[:user]
    @contract = session[:user].group.contract
    redirect_to :action => "new_contract" if @contract.nil?
  end

  def new_contract
    if request.post?
      @contract = Contract.new(params[:contract])
      @contract.group = session[:user].group
      @contract.state = 0 # por defecto estado = suspendido
      if @contract.save
        flash[:notice] = t("contract_created") 
        redirect_to :action => "contract"
      else
        render :action => "new_contract"
      end
    else
      @contract = Contract.new      

      # contract default values
      g = session[:user].group
      @contract.name        = h(g.name)
      @contract.co_nif      = h(g.nif)
      @contract.co_street   = h(g.address)
      @contract.co_cp       = h(g.zipcode)
      @contract.co_town     = h(g.city)
      @contract.co_province = h(g.province)
      a = session[:user].group.admin
      @contract.contact_name    = h(a.name + ' ' + a.surname)
      @contract.mail            = h(a.email)
      @contract.telf            = h(a.telephone)
      @contract.concurrentusers = nil 
    end
  end

  def edit_contract
    @contract = session[:user].group.contract
    redirect_to :action => "new_contract" and return if @contract.nil?
    
    if request.post?
      if @contract.update_attributes(params[:contract])
        flash[:notice] = t("contract_modified")
        redirect_to :action => "contract"
      end
    end
  end
  
  def pdf_contract
    @contract = session[:user].group.contract
    redirect_to :action => "new_contract" and return if @contract.nil?
    send_data render_to_pdf({:layout => false}), :type => 'application/pdf'
  end

  def pdf_contract_terms
    send_file "#{RAILS_ROOT}/public/doc/#{I18n.locale}/contract_terms.pdf", :type => 'application/pdf', :disposition => 'attachment'
  end

  private

  def authorize
    if session[:user].role != "groupadmin"
      flash[:notice] = t("invalid_login")
      redirect_to :controller => "ims"
    end
  end

  def set_app_vars
    @app = App.find params[:id]
    @group = session[:user].group
    @install = @app.installs.find_by_group_id(@group.id)
    if @install.nil?
      @install = Install.new
      @install.app = @app
      @install.group = @group
      @install.host = Host.find :first
      @install.status = "INSTALLING"
    end
    @installed = @group.apps.include?(@app)
    @host = @group.vhost
  end

end
