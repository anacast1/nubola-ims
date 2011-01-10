class ConsumValuesController < ApplicationController

  active_scaffold :consum_value do |config|
    config.label = "Límites contratados"
    config.columns[:consum_param].form_ui = :select
    config.list.columns = [:consum_param, :maxconsumitem, :limit]
    config.columns[:consum_param].clear_link
    config.columns[:consum_param].label = "Tipo de límite"
    config.columns[:limit].label = "Limitativo?"
    config.columns[:maxconsumitem].label = "Valor contratado"
  end
end
