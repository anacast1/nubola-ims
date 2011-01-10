class ContractsController < AdminRoleController

  active_scaffold :contracts

  active_scaffold :contract do |config|
    config.label='Contratos'
    config.actions.exclude :delete
    config.action_links.add :suspend, :type => :record, :inline => false, :label => 'Suspender'
    config.action_links.add :deletecontract, :type => :record, :inline => false, :label => 'Baja'
    config.list.columns = [ :group, :code, :state, :consum_values ]
    config.list.sorting = { :code => :desc }
    config.columns["code"].label = "Contrato"
    config.columns["group"].label = "Grupo"
    config.columns["state"].label = "Estado"
    config.columns["code"].label = "Número de contrato"
    config.columns["date"].label = "Fecha de contrato"
    config.columns["contract_type"].label = "Tipo de contrato"
    config.columns["co_nif"].label = "NIF"
    config.columns["co_street"].label = "Dirección"
    config.columns["co_cp"].label = "CP"
    config.columns["co_town"].label = "Población"
    config.columns["co_province"].label = "Provincia"
    config.columns["co_country"].label = "País"
    config.columns["contact_name"].label = "Nombre"
    config.columns["department"].label = "Departamento"
    config.columns["mail"].label = "Email"
    config.columns["telf"].label = "Teléfono"
    config.columns["concurrentusers"].label = "Usuarios concurrentes"
    config.columns["concurrentuserslimit"].label = "Limitativo?"
    config.columns["consum_values"].label = "Limites del contrato"
    config.create.link = nil
    config.create.columns = [ :group, :code, :date, :contract_type ]
    config.create.columns.add_subgroup "Empresa" do |e|
      e.add :co_nif, :co_street, :co_cp, :co_town, :co_province, :co_country
    end
    config.create.columns.add_subgroup "Persona contacto" do |p|
      p.add :contact_name, :department, :mail, :telf
    end
    config.create.columns.add_subgroup "Restricciones de usuario" do |r|
      r.add :concurrentusers, :concurrentuserslimit
    end
    config.update.columns = []
    config.update.columns << config.create.columns
    config.columns[:group].form_ui = :select
    config.columns[:consum_values].form_ui = :select
    config.nested.add_link("Albaranes", [:charges])
  end


  # suspender o reanudar un contrato
  def suspend
    c = Contract.find params[:id]
    c.change_state
    c.save
    redirect_to :action => 'list'
  end

  def deletecontract
    c = Contract.find params[:id]
    c.deletecontract
    c.save
    redirect_to :action => 'list'
  end

  protected

  # don't show deleted contracts
  def conditions_for_collection
    "state != 2"
  end

end
