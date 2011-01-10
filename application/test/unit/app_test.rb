require File.dirname(__FILE__) + '/../test_helper'

class AppTest < ActiveSupport::TestCase
  fixtures :apps

  def test_bad_dependencias
    a=apps(:one)
    a.save
    a.dependencias << a
    assert(!a.valid?, a.errors.inspect)
    assert_equal("can't be a dependency from himself",a.errors['base'])
  end

end
