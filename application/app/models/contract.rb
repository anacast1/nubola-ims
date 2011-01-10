# == Schema Information
# Schema version: 20090915080359
#
# Table name: contracts
#
#  id                   :integer(4)      not null, primary key
#  code                 :string(100)     default(""), not null
#  name                 :string(255)
#  group_id             :integer(4)
#  date                 :date
#  contract_type        :string(255)
#  contact_name         :string(255)
#  department           :string(255)
#  mail                 :string(255)
#  telf                 :string(255)
#  concurrentusers      :integer(4)
#  concurrentuserslimit :boolean(1)
#  created_at           :datetime
#  updated_at           :datetime
#  state                :integer(4)      default(0)
#  co_street            :string(255)
#  co_cp                :string(255)
#  co_town              :string(255)
#  co_province          :string(255)
#  co_country           :string(255)
#  co_nif               :string(255)
#

class Contract < ActiveRecord::Base
  has_many :consum_values
  has_many :consum_params, :through => :consum_values
  has_many :installs, :through => :group
  has_many :charges, :through => :group
  belongs_to :group
  validates_presence_of :group_id #, :code, :date
  validates_associated :consum_values
  validate :only_one_contract_by_group
  validate :group_must_have_apps
  validates_numericality_of :concurrentusers, :allow_nil => true, :only_integer=> true, :greater_than => 1, :message => I18n.t("two_or_more_concurrent")

  def only_one_contract_by_group
    if self.new_record?
      same_group_contract = Contract.find(:all, :conditions => ["group_id=? and state!=2",group_id])
    else
      same_group_contract = Contract.find(:all, :conditions => ["group_id=? and state!=2 and id!=?",group_id,id])
    end
    errors.add_to_base(I18n.t("group_has_already_been_taken")) if same_group_contract.size > 0
  end

  def group_must_have_apps
    return if group.nil?
    errors.add_to_base(I18n.t("group_must_have_installed_applications")) unless self.group.apps.size > 0
  end

  def before_save
    self.state = 1 if state.nil?
  end

  def after_save
    # if the contract has not been activated yet (date is nil)
    # when we change contract group data we reflect those changes to the
    # group
    if self.concurrentuserslimit
      self.group.numusers = self.concurrentusers
    end
    if self.date.nil?
      self.group.name = self.name
      self.group.nif = self.co_nif
      self.group.address = self.co_street    
      self.group.zipcode = self.co_cp
      self.group.city = self.co_town
      self.group.province = self.co_province
      self.group.country = self.co_country
    end
    self.group.contract_id = id
    self.group.save
  end

  ###### Send Xml Messages ######
  include MessageSender

  def xml4create
    newcontract
  end

  def xml4update
    modifycontract
  end

  def xml4destroy
    #contracts are not deleted, only changed to state=2
  end

  def change_state
    self.state = ( self.state == 1 ? 0 : 1 )
    @lastmsg = @msg = suspendcontract if self.state == 0
    if self.state == 1
      self.date = Time.now if self.date.nil?
	  self.code = self.id
      @lastmsg = @msg = resetcontract
    end
    send_xml_message
  end

  def deletecontract
    raise "can't delete a non-suspended contract" if self.state != 0
    self.state = 2
    builder = Builder::XmlMarkup.new(:indent => 2)
    @lastmsg = @msg = builder.deletecontract(:contract_id => code, :gid => group.id)
    send_xml_message
  end
  ##############################

  def newcontract
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.newcontract(:contract_id => code, :gid => group.id) { |b| to_xml b }
  end

  def modifycontract
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.modifycontract(:contract_id => code, :gid => group.id) { |b| to_xml b }
  end

  def suspendcontract
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.suspendcontract(:contract_id => code, :gid => group.id)
  end

  def resetcontract
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.resetcontract(:contract_id => code, :gid => group.id)
  end

  def to_label
    id.blank? ? nil : "Numero: #{code}" 
  end

  def apps
    group.apps
  end

  private

  def to_xml(b)
    b.contractdate(created_at.to_date.to_formatted_s(:xml))
    b.contracttype(contract_type)
    b.restrictions {
      b.concurrentusers(concurrentusers, :limit => concurrentuserslimit)
      apps.each do |app|
        b.application(:app_id => app.unique_app_id) {
          app.consum_params.each do |cp|
            cp.consum_values.find(:all, :conditions => ["contract_id=?",id]).sort.each do |cv|
              b << cv.to_xml(3)
            end
          end
        }
      end
    }
  end

end
