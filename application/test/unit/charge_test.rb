require 'test_helper'

class ChargeTest < ActiveSupport::TestCase

  fixtures :groups

  def setup
    @group = groups(:grupclient)
    @from = Time.gm(2007,11,1).beginning_of_month
    @to   = Time.gm(2007,11,1).end_of_month
  end

  def test_charge_ok
    charge = Charge.new :group => groups(:ingent), :period_from => Time.now, :period_to => Time.now + 1, :concept_type => 'fee', :price => 1, :quantity => 1
    assert charge.save
  end

  def test_charge_overlaps
    charge = Charge.new :group => groups(:ingent), :period_from => "2008-12-01", :period_to => "2009-01-01", :concept_type => 'fee', :price => 1, :quantity => 1
    # Concept type ya existe para el grupo y el periodo
    assert !charge.save
  end

  def test_charge_users
    charge = Charge.new(:group        => @group,
                        :period_from  => @from,
                        :period_to    => @to,
                        :concept_type => "users"
    )
    charge.set_users
    assert_equal(0,charge.quantity) # el unico usuario que entra, esta en demo

    u = users(:grupclient_user)
    u.apps << apps(:crm)
    assert u.save # ahora el usuario ya no esta en demo, pues crm no lo esta

    charge.set_users
    assert_equal(1,charge.quantity.to_i)
  end

  def test_charge_space
    charge = Charge.new(:group        => @group,
                        :period_from  => @from,
                        :period_to    => @to,
                        :concept_type => "space"
    )
    charge.set_space
    assert_equal(1000,charge.quantity.to_i)

#    require "ruby-debug" ; debugger
    i = installs(:grupclient_reports)
    i.created_at = Time.now - 40.days # hacemos que reports ya no este en demo
    assert i.save

    @group.reload
    charge = Charge.new(:group        => @group,
                        :period_from  => @from,
                        :period_to    => @to,
                        :concept_type => "space"
    )

    charge.set_space
#    require "ruby-debug" ; debugger
    assert_equal(3000,charge.quantity.to_i)
  end

  def test_charge_host
    charge = Charge.new(:group        => @group,
                        :period_from  => @from,
                        :period_to    => @to,
                        :concept_type => "host"
    )
    charge.set_host
    assert_equal(0,charge.quantity)

    charge = Charge.new(:group        => groups(:ingent),
                        :period_from  => @from,
                        :period_to    => @to,
                        :concept_type => "host"
    )
    charge.set_host
    assert_equal(1,charge.quantity)

    from = Time.gm(2007,11,1)
    to   = from.end_of_month
    charge = Charge.new(:group        => groups(:ingent),
                        :period_from  => from,
                        :period_to    => to,
                        :concept_type => "host"
    )
    charge.set_host
    assert_equal(0.7,charge.quantity.to_f)
  end

  def test_charge_fee
#    from = Time.gm(2007,11,1)
#    to   = from.end_of_month
#    charge = Charge.new(:group        => groups(:ingent),
#                        :period_from  => from,
#                        :period_to    => to,
#                        :concept_type => "fee"
#    )
#    charge.set_fee
#    assert_equal(0.7,charge.quantity.to_f)

    charge = Charge.new(:group        => groups(:ingent),
                        :period_from  => Time.now.beginning_of_month,
                        :period_to    => Time.now.end_of_month,
                        :concept_type => "fee"
    )
    charge.set_fee
    assert_equal(1,charge.quantity.to_f)
  end

end
