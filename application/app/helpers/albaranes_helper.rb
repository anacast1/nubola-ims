module AlbaranesHelper
  def render_menu
      render :partial=> 'group_admin/albaranes_header'
  end

  def period_from_column(record)
    record.period_from.strftime('%m/%Y')
  end

end
