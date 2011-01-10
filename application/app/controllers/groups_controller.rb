# -*- coding: utf-8 -*-
class GroupsController < AdminRoleController
  LIST_COLS = ["name", "contract", "academies", "address", "city", "zipcode", "country", "active", "client", "created_at"]
  CRE_COLS =  ["name", "address", "city", "zipcode", "country", "nif", "logo_image"]
  UPD_COLS = CRE_COLS + ["demo_ends"]
  COLS = ["academies"]

  active_scaffold :group do |config|
    config.label = "groups"
    # columna virtual
    config.columns << :active
    # columna virtual
    config.columns << :client
    # columna virtual
    config.columns << :academies
    config.columns["academies"].label = "Academias"
    config.list.columns = LIST_COLS
    config.list.sorting = { :created_at => :desc }
    config.create.columns = []
    config.create.columns.add_subgroup "Grupo" do |g|
      g.add CRE_COLS
    end
    config.create.columns.add_subgroup "Academias" do |g|
      g.add COLS
    end
    config.update.columns = []
    config.update.columns.add_subgroup "Grupo" do |g|
      g.add UPD_COLS
    end
    config.update.columns.add_subgroup "Academias" do |g|
      g.add COLS
    end
  end

  protected

    def before_create_save(record)
      if params[:record][:academies]
        params[:record][:academies].each_value do |app_index|
          Install.create!(:app_id => app_index["id"].to_i, :group_id => record.id, :host_id => Host.find_by_hostname(Setting.shared_host).id, :status => "OK")
        end
      end
    end

    def before_update_save(record)

      new_ids = Array.new
      if params[:record][:academies]
        params[:record][:academies].each_value do |app_index|
          new_ids.push(app_index["id"].to_i)
        end
      end

      old_ids = record.apps.delete_if{|app| app.is_academy == false}.collect{|academy| academy.id}
      if old_ids
        old_ids.each do |id|
          unless new_ids.index(id)
            academy = App.find_by_id(id)
            academies_to_be_deleted_from = Array.new
            academies_to_be_deleted_from << academy
            record.users.each do |u|
              bind = Bind.find_by_app_id_and_user_id(id, u.id)
              if bind
                message = u.deluser_message academies_to_be_deleted_from
                unless system("#{Setting.oappublish} 'IMS' '#{message}'")
                  logger.info("Problem publishing deluser message")
                end
                # unbind user from academy
                bind.update_attributes!(:status => "UNBINDING")
              end
            end
            # no faria falta, però així amb sort quan 
            # acabi potser ja ha arribat la resposta
            may_sleep 5
          end
          Install.find_by_app_id_and_group_id_and_host_id(id, record.id, Host.find_by_hostname(Setting.shared_host).id).destroy
        end
      end


      new_ids.each do |id|
        Install.create!(:app_id => id, :group_id => record.id, :host_id => Host.find_by_hostname(Setting.shared_host).id, :status => "OK")
      end

    end
end
