require 'test_helper'

# comprova que s'envien tots els missatges
# corresponents segons el cicle de vida dels objectes

class MessageSenderTest < ActiveSupport::TestCase
  fixtures :users, :groups, :apps, :contracts, :installs

  def test_login
    user = User.authenticate('user','ingent')
    assert user
    user.send_login_message('fake_session_id4ee71077bf8e5d6a6')
    assert_match(/login/, user.messagesent)
  end

  def test_logout
    user = users(:ingent_user)
    assert user
    user.send_logout_message('fake_session_id4ee71077bf8e5d6a6')
    assert_match(/logout/, user.messagesent)
  end

  def test_adduser
    user = User.new :login => 'test_adduser'
    user.save
    # TODO: moure l'enviament de missatges a after_create
  end

  def test_deluser
    user = users(:ingent_user)
    #user.destroy
    # TODO: moure l'enviament de missatges a before_destroy
  end

  def test_addgroup
    group = Group.new :name=>'test_addgroup', :nif=>'77310000H'
    group.save
    # TODO: moure l'enviament de missatges a after_create
  end

  def test_delgroup
    group = groups(:ingent)
    #group.destroy
    # TODO: moure l'enviament de missatges a before_destroy
  end

  def test_install
    app = apps(:crm)
    group = groups(:ingent)    
    # TODO: moure l'enviament de missatges a after_create
  end
  
  def test_uninstall
    install = installs(:ingent_crm)
    install.destroy
    # TODO: moure l'enviament de missatges a before_destroy
  end

  def test_newcontract
    contract = Contract.new :group=>groups(:en_demo), :code=>'test_newcontract', :date=>Time.now.to_date
    assert contract.save!
    assert_match(/newcontract/, contract.messagesent)    
  end
  
  def test_modifycontract
    contract = contracts(:ingent)
    contract.contract_type = "test_modifycontract"
    assert contract.save!
    assert_match(/modifycontract/, contract.messagesent)    
  end

  def test_suspend_and_reset_contract
    contract = contracts(:ingent)
    contract.change_state
    assert_match(/suspendcontract/, contract.messagesent)    
    contract.change_state
    assert_match(/resetcontract/, contract.messagesent)    
  end

  
end
