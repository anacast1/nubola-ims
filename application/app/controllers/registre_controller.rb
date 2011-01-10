class RegistreController < AdminRoleController

  COLS = [ :action, :user, :group, :app, :text, :created_at, :amount]
  
  active_scaffold :registre do |config|
    config.label='Eventos'
    config.list.columns = COLS - [:text]
    config.show.columns = COLS
    config.actions = [ :list, :show, :nested, :search ]
    config.list.per_page = 25
    config.list.sorting = { :created_at => :desc }
    config.columns["user"].clear_link
    config.columns["group"].clear_link
    config.columns["app"].clear_link
  end
end
