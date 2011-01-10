module UsersHelper
  def render_menu
    render :partial=> 'root_admin/root_header'  
  end

  def password_form_column(record, input_name)
    password_field(:record, :password, {:class => 'password-input text-input' })
  end

  def password_confirmation_form_column(record, input_name)
    password_field(:record, :password_confirmation, {:class => 'password-input text-input' })
  end

  def login_form_column(record, input_name)
    disabled = record.new_record? ? false : true
    text_field(:record, :login, { :value => record.login, :disabled => disabled, :class => 'text-input' })
  end

  def role_form_column(record, input_name)
    select :record, :role, 
           {"Administrador técnico  (root)"  => "platformadmin",
            "Administrador clientes (admin)" => "privilegeduser",
            "Usuario administrador de grupo" => "groupadmin",
            "Usuario normal" => "user"}
  end

  def role_column(record)
    case record.role
      when "groupadmin":
        "Usuario administrador de grupo"
      when "user":
        "Usuario normal"
      when "platformadmin":
        "<b>Administrador técnico  (root)</b>"
      when "privilegeduser":
        "<b>Administrador clientes (admin)</b>"
    end
  end

end
