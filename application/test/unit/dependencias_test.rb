require File.dirname(__FILE__) + '/../test_helper'

class DependenciasTest < Test::Unit::TestCase
  fixtures :apps

  def test_dependencias_crea_borra_dependiente
    apps(:reports).dependencias << apps(:crm)
    assert apps(:crm).dependientes.include?(apps(:reports))

    apps(:reports).dependencias.delete(apps(:crm))
    assert_equal 0, apps(:crm).dependientes.length
  end

   def test_dependientes_crea_borra_dependencia
    apps(:crm).dependientes << apps(:reports)
    assert apps(:reports).dependencias.include?(apps(:crm))

    apps(:crm).dependientes.delete(apps(:reports))
    assert_equal 0, apps(:reports).dependencias.length
  end

end
