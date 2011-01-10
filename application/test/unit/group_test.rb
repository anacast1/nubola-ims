require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups

  def setup
    @group = groups(:grupclient)
    @from  = Time.now.beginning_of_month
    @to    = Time.now.end_of_month
  end

  def test_have_data
    assert_kind_of Group, groups(:administration)
    assert_kind_of Group, groups(:ingent)
  end

  def test_concurrency
    conc = @group.concurrency(@from, @to)
    assert_equal(0,conc[0]) # el unico usuario que entra, esta en demo
    u = users(:grupclient_user)
    u.apps << apps(:crm)
    u.save # ahora el usuario ya no esta en demo, pues crm no lo esta
    conc = @group.concurrency(@from, @to)
    assert_equal(1,conc[0])
  end

  def test_max_space
    crm = apps(:crm)
    space = @group.max_space(@from, @to, true)
    assert_equal(@from.beginning_of_day.to_i,space.keys.sort[0])
#    assert_equal(1,space[(Time.now - 1.hour).beginning_of_day.to_i].size)
    assert_equal(1000,space[(Time.now - 1.hour).beginning_of_day.to_i][crm.id])

    inst = installs(:grupclient_reports)
    assert_equal(true, inst.demo?)
    inst.created_at = (Time.now - 2.month)
    assert inst.save
    inst.reload
    @group.reload
    assert_equal(false, inst.demo?)
    space = @group.max_space(@from, @to, true)
    assert_equal(@from.beginning_of_day.to_i,space.keys.sort[0])
    assert_equal(2,space[(Time.now - 1.hour).beginning_of_day.to_i].size)
    assert_equal(2000,space[(Time.now - 1.hour).beginning_of_day.to_i][inst.app.id])
  end

  def test_platform_admin
    assert groups(:administration).platform_admin?
    assert !groups(:ingent).platform_admin? 
  end

end
