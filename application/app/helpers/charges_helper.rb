module ChargesHelper
  def render_menu
    render :partial=> 'root_admin/root_header'  
  end

  def concept_type_column(record)
    record.concept
  end
  
end
