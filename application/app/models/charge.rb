# == Schema Information
# Schema version: 20090915080359
#
# Table name: charges
#
#  id           :integer(4)      not null, primary key
#  group_id     :integer(4)
#  concept_type :string(20)
#  period_from  :date
#  period_to    :date
#  quantity     :decimal(10, 2)
#  price        :decimal(10, 2)
#  created_at   :datetime
#  updated_at   :datetime
#

class Charge < ActiveRecord::Base

  belongs_to :group
  belongs_to :contract
 
  CONCEPTS = {
    'fee' => 'Cuota mensual pataforma',
    'users' => 'Usuarios adicionales',
    'space' => 'Espacio adicional',
    'bw' => 'Transferencia adicional',
    'host' => 'Máquina virtual'
  }

  validates_inclusion_of :concept_type, :in => CONCEPTS
  validates_associated :group
  validates_presence_of :period_from, :period_to, :quantity, :price
  validates_uniqueness_of :concept_type, :scope => [:group_id, :period_from, :period_to], :message => 'ya existe para el grupo y el periodo'
  validate :validate_period
  
  def validate_period
    errors.add_to_base("'To' es menor que 'From'") if period_to && period_from && period_to < period_from
  end
  
  def concept
    CONCEPTS[self.concept_type]
  end
  
  def self.create_all(group, from, to)
    raise "El grupo #{group.name} no tiene contrato" if group.contract.nil?
    charges = []
    CONCEPTS.each do |k,v|
      c = Charge.new :group => group, :period_from => from, :period_to => to
      if c.send("set_#{k}") and c.quantity > 0 # nomes desem si la quantitat es > 0 
        c.concept_type = k
        c.save
        charges << c
      end
    end
    charges
  end
  
  def set_fee
    self.quantity = 0
    if group.contract.created_at < period_to
      self.quantity = 1
    end
    self.price = Setting.fee_price * self.quantity
    return true 
  end

  def set_users
    # ull: no te en compte els usuaris ja connectats abans de les 00:00h del primer dia
    # potser caldria fer fora tots els usuaris a les 00:00 del dia 1 de cada mes
    conc = group.concurrency(period_from, period_to)
    if conc[0] <= Setting.included_users
      self.quantity = 0
    else
      self.quantity = conc[0] - Setting.included_users
    end
    self.price = Setting.users_price
    return true
  end

  def set_space
    # espai ocupat > màxim permès segons Setting
    # q dia = suma de l'espai ocupat per totes les aplicacions cada dia
    # nota: no tenir en compte les aplicacions en demo
    # q = màxim mensual de q dia
    # import = q * preu segons Setting
    space = group.max_space(period_from, period_to)
    if space <= Setting.included_space
      self.quantity = 0
    else
      self.quantity = (space - Setting.included_space) / 1024.0
    end
    self.price = Setting.space_price
    return true
  end

  def set_bw
    #TODO: no tenim el consum necessari
    bw = 0
    if bw <= Setting.included_bw
      self.quantity = 0
    else
      self.quantity = bw - Setting.included_bw
    end
    self.price = Setting.bw_price
    return true
  end

  def set_host
    self.quantity = 0
    self.price = 0
    unless group.vhost.nil?
       
    end
    return true
  end

  def to_label
    concept
  end

  def group_name
    group.name
  end

  def period
    "#{period_from} - #{period_to}"
  end

  def total
    price * quantity
  end

  private

  def percentage_of_month(concept)
    # calculamos el porcentaje de los dias que lleva de contrato en el mes
    dim = Time.days_in_month(period_from.month, period_from.year)
    d   = dim - group.send(concept).created_at.day + 1
    return d.to_f / dim
  end
  
end
