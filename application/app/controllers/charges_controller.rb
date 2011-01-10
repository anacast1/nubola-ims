class ChargesController < AdminRoleController

  helper :application

  # no hereda de RootAdmin o GroupAdmin pq pot veure-ho tant groupadmin com root
  before_filter :login_required
  before_filter :authorize

  COLS = [ :group, :group_name, :concept_type, :period, :price, :quantity, :total]

  active_scaffold do |config|
    config.label='Albaranes'
    config.actions.exclude :create, :delete, :update, :show
    config.action_links.add "create_new", { :page=>true, :label=>" --&nbsp;&nbsp;Generar nuevos albaranes"}
    config.columns = COLS
    config.list.columns = COLS - [:group]
    config.columns[:group_name].includes = [:group]
    config.columns[:group_name].sort_by :sql => "groups.name SORT, concat(period_from, period_to) DESC"
    config.columns[:group_name].search_sql = "groups.name"
    config.search.columns << :group_name
    config.columns[:period].includes = [:group]
    config.columns[:period].sort_by :sql => "concat(period_from, period_to) SORT, groups.name"
    config.list.sorting = [{:period => :desc},{:group_name => :asc}]
    config.list.per_page = 50
  end
  
  # generar nuevos albaranes
  def create_new
    @charges = []
    @groups = Group.find(:all)

    older_from = Time.at(0).to_date
    newer_from = first_day_of_month(Time.now.to_date)
    newer_charge = Charge.first(:order => "period_from DESC")

    unless (newer_charge.nil?)
      older_from = newer_charge.period_from
      Charge.destroy_all(["period_from >= ?", older_from])
    end

    @from = older_from
    while ((newer_from <=> @from) != -1)
      @to = @from + Time.days_in_month(@from.month, @from.year)

      @groups.each do |group|
        if (!group.contract.nil? && group.contract.state != 2)
          @charges += Charge.create_all(group, @from, @to)
        end
      end

      @from = @to
    end

    @from = older_from
    @to = newer_from + Time.days_in_month(newer_from.month, newer_from.year)
  end

  private

  # override active_scaffold method
  def build_order_clause(sorting)
    return nil if sorting.nil? or sorting.sorts_by_method?

    # unless the sorting is by method, create the sql string
    order = []
    sorting.each do |clause|
      sort_column, sort_direction = clause
      sql = sort_column.sort[:sql]
      next if sql.nil? or sql.empty?

      if sql =~ /SORT/
        order << sql.gsub(/SORT/,sort_direction)
      else
        order << "#{sql} #{sort_direction}"
      end

    end

    order = order.join(', ')
    order = nil if order.empty?

    order
  end

  # ara no desem quantitats <=0 pero encara n'hi ha a la bbdd
  def conditions_for_collection
    ["quantity != ?", 0.00]
  end

  def first_day_of_month(date)
    Date.new(date.year,date.month,1)
  end

end
