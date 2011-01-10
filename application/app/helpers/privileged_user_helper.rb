module PrivilegedUserHelper

  def render_menu
    if current_page?(:controller=>'privileged_user', :action=>'index')
      render :partial=> 'shared/controll_panel_head'
    else
      # TODO: difícil factor comú ...
    end
  end

end
