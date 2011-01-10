# -*- coding: utf-8 -*-
require 'test_helper'

class ContractTest < ActiveSupport::TestCase
  fixtures :contracts

  def test_to_xml
    c=contracts(:ingent)
#    c.consum_values = ConsumValue.find(:all)

    xml = <<EOF
<newcontract .*>
  <contractdate>2007-11-10</contractdate>
  <contracttype>Cuota fija</contracttype>
  <restrictions>
    <concurrentusers limit="false">10</concurrentusers>
    <application app_id="SUGARCRM">
      <maxconsumitem .*>5</maxconsumitem>
    </application>
    <application app_id="SUGARCRMREPORTS">
    </application>
  </restrictions>
</newcontract>
EOF

    # utilitzem expresió regular per comparar el XML
    # perquè l'ordre dels artibuts no està definit i pot ser qualsevol
    assert_match(/#{xml}/,c.newcontract)
  end

  def test_suspend_contract
    c=contracts(:ingent)
    r = c.suspendcontract
    assert_match(/suspendcontract/, r)
    assert_match(/contract_id="20071130001"/, r)
    assert_match(/gid="#{Fixtures.identify(:ingent)}"/, r)
  end

  def test_reset_contract
    c=contracts(:ingent)
    r = c.resetcontract
    assert_match(/resetcontract/, r)
    assert_match(/contract_id="20071130001"/, r)
    assert_match(/gid="#{Fixtures.identify(:ingent)}"/, r)
  end

  def test_delete_contract
    c=contracts(:ingent)
    e=assert_raise RuntimeError do
      c.deletecontract
    end
    assert_match(/can't delete a non-suspended contract/,e.message)
    c=contracts(:ingent)
    c.change_state
    c.deletecontract
    assert_match(/deletecontract/, c.messagesent)
    assert_match(/contract_id="20071130001"/, c.messagesent)
    assert_match(/gid="#{Fixtures.identify(:ingent)}"/, c.messagesent)
  end

  def test_activate_new_contract_sets_date
    c = Contract.new
    c.group = groups(:en_demo)
    assert_equal 0, c.state
    assert_nil c.date
    c.change_state
    assert_equal 1, c.state
    assert_not_nil c.date
  end

  def test_activate_old_contract_doesnt_sets_date
    c = contracts(:ingent)
    assert_equal 1, c.state
    date = c.date

    c.change_state
    assert_equal 0, c.state
    assert_equal date, c.date

    c.change_state
    assert_equal 1, c.state
    assert_equal date, c.date
  end
  
  def test_saving_new_contract_modifies_group_data
    # a "new contract" is a contract with date nil
    c = Contract.new
    c.group = groups(:en_demo)
    c.name = "Invented Name"
    c.co_country = "es"
    c.co_street = "street adress 1"
    c.co_town = "town 1"
    c.co_cp = "08720"
    c.co_province = "province 1"
    assert c.save
    group = groups(:en_demo).reload
    assert_equal c.name, group.name
  end
  
  def test_saving_old_contract_doesnt_modify_group_data
    # a "new contract" is a contract with date nil
    c = contracts(:ingent)
    c.name = "Invented Name"
    assert c.save
    group = groups(:ingent).reload
    assert_not_equal c.name, group.name
  end
  
end
