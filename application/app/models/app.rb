# == Schema Information
# Schema version: 20090915080359
#
# Table name: apps
#
#  id                   :integer(4)      not null, primary key
#  unique_app_id        :string(100)     default(""), not null
#  name                 :string(100)     default(""), not null
#  url                  :string(100)
#  homepage_url         :string(50)
#  logo_image           :string(255)
#  instance_basename    :string(100)
#  end_user_available   :boolean(1)      not null
#  admin_user_available :boolean(1)      not null
#  has_users            :boolean(1)      default(TRUE)
#  basesize             :integer(4)
#  ram                  :integer(4)
#  cpu                  :integer(4)
#  description          :text
#  short                :text
#  fee                  :float
#  host_id              :integer(4)      default(1)
#  is_academy           :boolean(1)      not null
#

class App < ActiveRecord::Base
  has_many :parameters
  has_many :installs
  has_many :binds
  belongs_to :host
  has_many :groups, :through => :installs
  has_many :hosts,  :through => :installs
  has_many :users,  :through => :binds
  has_and_belongs_to_many :dependencias,
    :class_name => "App",
    :join_table => "relationships",
    :foreign_key => "dependiente_id",
    :association_foreign_key => "dependencia_id" 
  has_and_belongs_to_many :dependientes,
    :class_name => "App",
    :join_table => "relationships",
    :foreign_key => "dependencia_id",
    :association_foreign_key => "dependiente_id"
  has_many :registres
  has_many :consum_params

  file_column :logo_image, :magick => { :geometry => "48x48"} rescue Mysql::Error 

  validate :cant_depend_on_self
  validates_presence_of :unique_app_id, :name, :url, :host, :basesize, :ram, :cpu
  validates_uniqueness_of :name, :unique_app_id
  validate :uniqueness_of_uri_combination

  def cant_depend_on_self
    errors.add_to_base("can't be a dependency from himself") if self.dependencia_ids.include?(self.id)
  end

  def uniqueness_of_uri_combination
    if instance_basename.nil?
      ans = App.find_all_by_url(url).reject{|an| an == self}
      errors.add_to_base("Single instance applications must have a unique URL") if ans.length > 0
    else
      ans = App.find_all_by_host_id_and_url(host, url).reject{|an| an == self}
      errors.add_to_base("Multiple instance applications must have a unique Host+URL combination") if ans.length > 0
    end
  end

  def app_dependencias=(attrs)
    dependencias.delete_all unless new_record?
    attrs.each do |app_index|
      dependencias << App.find(app_index)
    end    
  end

  def consums
    (registres.collect { |r| r if r.type == "Consum" }).compact
  end

  def install_for(group)
    installs.each do |i|
      return i if i.group == group
    end
  end

  def short_description
	unless short.nil?
      return short
    end
	return I18n.t("no_description")
  end

  def long_description
	unless description.nil?
      return description
    end
	return I18n.t("no_description")
  end


  def add_users(new_users)
    for user in new_users
      self.users << user
    end
  end  

  def add_group(new_group)
    self.groups << new_group
  end

  def find_user_parameters
    parameters.find_all_by_kind('user') + parameters.find_all_by_kind('global')
  end

  def find_group_parameters
    parameters.find_all_by_kind('group') + parameters.find_all_by_kind('global')
  end

  def to_label
    name
  end

  protected

  def validate
    if url
      res = App.find_all_by_host_id_and_url(host, url).reject{|a| a == self}
      if !res.nil? && res.length > 0
        errors.add(:url, "host+url must be unique and #{res[0].name} already has these values")
      end
    end
  end

end
