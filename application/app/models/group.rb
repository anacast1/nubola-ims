# == Schema Information
# Schema version: 20090915080359
#
# Table name: groups
#
#  id          :integer(4)      not null, primary key
#  name        :string(100)     default(""), not null
#  address     :string(100)     default(""), not null
#  city        :string(100)     default(""), not null
#  zipcode     :string(5)       default(""), not null
#  country     :string(100)     default(""), not null
#  nif         :string(9)
#  created_at  :datetime
#  logo_image  :string(255)
#  numusers    :integer(4)      default(0), not null
#  loginusers  :integer(4)      default(0), not null
#  contract_id :integer(4)
#  demo_ends   :datetime
#  province    :string(255)
#  size        :string(255)
#  sector      :string(255)
#

class Group < ActiveRecord::Base
  has_and_belongs_to_many :hosts
  has_many :users, :dependent => :destroy
  has_many :group_settings
  has_many :installs
  has_many :apps, :through => :installs
  has_many :registres
  has_one :contract
  has_many :charges

  file_column :logo_image, :magick => { :geometry => "48x48"} rescue Mysql::Error

  def before_save
    shared_host = Host.find_by_hostname(Host.hostname_compartit)
    hosts << shared_host unless shared_host.nil? or hosts.include? shared_host 
  end

  # per controlar la data de final de demo
  def before_create
    write_attribute(:demo_ends, Time.now + 30.days)
  end

  # Returns group admin user
  def admin
    users.find :first, :conditions => ['role = ?','groupadmin']
  end

  def platform_admin?
    roles =  users.map{|u| u.role}
    roles.include?("platformadmin") or roles.include?("privilegeduser")
  end

  def installedApps
    apps.collect { |app|
      if (app.url =~ /^http/)
        url  = app.url
      else                                                                                   
        host = Install.find_by_app_id_and_group_id(app.id, id).host.hostname 
        url  = "https://#{host}/#{app.url}/#{app.instance_basename}_#{id}"
      end
      "#{app.unique_app_id} => #{url}"
    } * ", "
  end

  # Returns group admin email
  def email
    admin.email
  end

  # Is client if has an active contract
  def client
    return (!contract.nil? && contract.state == 1)
  end
  
  def client?
    client
  end

  # A group is active if it is not an expired demo group
  def active
    return (platform_admin? or demo? or client?)
  end

  def active?
    active
  end
  
  def demo
    return ((demo_ends <=> Time.now) != -1 and (contract.nil? or contract.code.blank?) )
  end
  
  def demo?
    demo
  end
  
  # Campo virtual
  # si no tiene demo_ends la calculamos ahora ...
  def demo_ends
    write_attribute(:demo_ends, created_at + 30.days) if read_attribute(:demo_ends).nil?
    read_attribute(:demo_ends)
  end

  def academies
    self.apps.delete_if{|app| app.is_academy == false}.collect{|app| app.unique_app_id}
  end

  def academies=(attrs = nil)
  end

  #TODO: de moment l'ims nomes permet instal.lar apps d'una en una
  def install_message(apps_to_install, host=Setting.shared_host, originalhost=Setting.shared_host)
    # XML INSTALL MESSAGE
    # <install id="id" host="hostname" original_host="hostname">
    #   <applications>
    #     <app id="application_id">
    #       <param name="parameter_name">parameter_value</param>
    #       ......................
    #     </app>
    #     .......
    #   </applications>
    # </install>
    originalhost = host if originalhost.nil?
    builder = Builder::XmlMarkup.new
    builder.install("gid" => id, "host" => host, "original_host" => originalhost){
      builder.applications{
        apps_to_install.each do |a|
          builder.app("id" => a[:application].unique_app_id){
            a[:parameters].each_pair do |pid, pvalue|
              builder.param(pvalue, "name" => Parameter.find(pid).name)
            end
          }
        end
      }
    }
  end

  def uninstall_message(apps_to_uninstall, host=Setting.shared_host)
    # XML UNINSTALL MESSAGE
    # <uninstall id="id" host="hostname">
    #   <applications>
    #    <app id="application_id">
    #    </app>
    #    .......
    # </applications>
    # </uninstall>
    builder = Builder::XmlMarkup.new
    builder.uninstall("gid" => id, "host" => host){
        builder.applications{
          apps_to_uninstall.each do |a|
            builder.app("id" => a.unique_app_id)
          end
        }
    }
  end

  def backup_message(apps_to_backup, host=Setting.shared_host)
    # XML BACKUP MESSAGE
    # <backup id="id" host="hostname">
    #   <applications>
    #    <app id="application_id">
    #    </app>
    #    .......
    #   </applications>
    # </backup>
    builder = Builder::XmlMarkup.new
    builder.backup("gid" => id, "host" => host){
        builder.applications{
          apps_to_backup.each do |a|
            builder.app("id" => a.unique_app_id)
          end
        }
    }
  end

  def restore_message(date, apps_to_restore, host=Setting.shared_host, originalhost=Setting.shared_host)
    # XML RESTORE MESSAGE
    # <restore id="id" host="hostname" original_host="hostname">
    #   <date>...</date>
    #   <applications>
    #     <app id="application_id">
    #     </app>
    #       .......
    #  </applications>
    # </restore>
    builder = Builder::XmlMarkup.new
    builder.restore("id" => id, "host" => host, "original_host" => originalhost){
        builder.date(date)
        builder.applications{
          apps_to_restore.each do |a|
            builder.app("id" => a.unique_app_id)
          end
        }
    }
  end

  # This method looks if the group has a setting for a given parameter, and
  # returns that setting. It works like this:
  # 1 -> Search in group_setting
  # 2 -> If it finds nothing, search parameter default value.
  def find_group_setting_value(parameter)
    # Search in database
    if group_setting = group_settings.find_by_parameter_id(parameter.id)
      return group_setting.value
    end
 
    return parameter.default_value
  end

  def build_message_group_id groupname
    message_group_id = groupname.downcase
    if (message_group_id = message_group_id.delete(" ")) == nil
      message_group_id = groupname.downcase
    end
    message_group_id
  end

  def build_message_app_id appname
    message_app_id = appname.upcase
    if (message_app_id = message_app_id.delete(" ")) == nil
      message_app_id = name.upcase
    end
    message_app_id
  end

  # Returns a field value specifying the field as a string.
  # Ex: get_field_name("Group.name")
  def get_field_by_name field
    self.send field.split(".")[1].to_sym
  end

  validates_uniqueness_of :name # :message => "El nombre de empresa ya existe"
  #validates_uniqueness_of :nif #, :message => "El NIF de empresa ya existe"
  validates_presence_of :name #, :message => "El nombre de empresa está en blanco"
  #validates_presence_of :nif #, :message => "El NIF de empresa está en blanco"
  # :city, :zipcode, :address, :country
  #validates_numericality_of :zipcode
  #validates_length_of :zipcode, :is => 5

  # returns Virtual Host of this group
  # if it has no VH, returns nil
  def vhost
    hosts.each do |host|
      return host if host.virtual?
    end
    return nil
  end

  def to_label
    return name
  end

  def users_logged_in(from,to)
    group_where = id == -1 ? "" : "group_id='#{id}' and "
    sql = ActiveRecord::Base.connection()
    logins = sql.execute("select distinct(user_id) from registres where #{group_where} action='login' and created_at between '#{from.to_s(:db)}' and '#{to.to_s(:db)}'")
    retval = logins.num_rows
    logins.free
    return retval
  end

  # returns [ concurrency, [connecteduser1, ..., connecteduserN] ]
  def concurrency(from, to, last_period_connected_users=[], from_early=nil)
    period = Period.new(from, to, self, last_period_connected_users)
    unless from_early.nil?
      period.process_old(from_early)
    end
    period.process
    return [period.concurrency, period.connected_users]
  end

  def max_space(from,to,test=false)
    if id == -1
      groupwhere=""
      installs = Install.find :all
    else
      installs = self.installs
      groupwhere="group_id = #{id} and"
    end
    installs.reject!{ |i| i.app.is_academy }
    apps = {}
    installs.each do |i|
      apps[i.app.id] = 0
    end
    mes = period_hash(from,to,apps)
    installs.each do |i|
      next if i.demo? or i.host.virtual? # no tener en cuenta las aplicaciones en demo o instaladas en host virtual
      conditions = ["#{groupwhere} action = 'consum' and text like '%STORAGE%' and app_id = ? and created_at between ? and ?", i.app_id, from.to_s(:db), to.to_s(:db) ]
      consums = Consum.find :all, :conditions => conditions
      consums.each do |consum|
        ap_id = consum.app.id
        day = consum.created_at.beginning_of_day.to_i
        mes[day][ap_id] = consum.amount - consum.app.basesize if mes[day][ap_id] < consum.amount - consum.app.basesize
      end
    end
    return mes if test
    used_days = mes.collect{|day,apps| apps.reject{|app,amount| amount<=0 } }.reject{|apps| apps == {} }
    total     = 0.0
    used_days.each do |day|
      total  += day.collect{|app,amount| amount}.sum.to_f
    end
    total    /= used_days.size.to_f
    return total
  end

  private

  # omple un hash amb una clau (el dia .to_i) i un valor per cada dia d'un periode
  #TODO: es podria posar dins de lib/period.rb ?
  def period_hash(from,to,valor)
    period = {}
    day = from.beginning_of_day
    while day < to.end_of_day
      period[day.to_i] = valor.dup
      day += 1.day
    end
    return period
  end

end
