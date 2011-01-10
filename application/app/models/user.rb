# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20090915080359
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  login               :string(80)      default(""), not null
#  password_hash       :string(40)      default(""), not null
#  group_id            :integer(4)      default(0), not null
#  role                :string(20)      default(""), not null
#  name                :string(100)     default(""), not null
#  surname             :string(100)     default(""), not null
#  status              :string(20)      default("active"), not null
#  telephone           :string(20)
#  mobile              :string(20)
#  email               :string(50)      default(""), not null
#  user_image          :string(255)
#  plain_password      :string(40)      default(""), not null
#  confirmed           :boolean(1)      not null
#  confirmation_string :string(255)
#  wallpaper           :string(255)
#  default_wallpaper   :string(255)     default("wallpaper_1.jpg")
#  created_at          :datetime
#

require 'digest/sha1'
require 'base64'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  belongs_to :group
  has_many :user_settings, :dependent => :destroy
  has_many :binds
  has_many :apps, :through => :binds
  has_many :registres

  file_column :user_image, :magick => { :geometry => "48x48"} rescue Mysql::Error
  file_column :wallpaper,  :magick => { :versions => {"thumb" => "100x500", "normal" => "1280x960"} } rescue Mysql::Error

  # Please change the salt to something else, 
  # Every application should use a different one 
  @@salt = 'oaproject'
  cattr_accessor :salt
  attr_accessor :password
  attr_protected :password_hash

  include MessageSender
  def after_create
  end
  
  def before_update
  end

  def after_update
  end

  # Authenticate a user. 
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    user = find :first, :conditions => ["login = ? AND password_hash = ?", login, sha1(pass)]
    if user.nil?
      user = "login error"
    elsif user.group.nil? || !user.group.active?
      user = "group inactive"
    elsif user.status != "active"
      user = "user inactive"
    elsif !user.confirmed?
      user = "user not confirmed"
    end
    user
  end 

  # Un usuari es demo si tots els installs pel seu grup
  # de les seves apps es van fer fa menys d'un mes.
  def demo?
    return group.demo?
  end
  
  def groupname
    return group.name
  end

  def send_login_message(session_id)  
    # <login id="unique_user_id" sid="valid_user_session_id" gid="id"/>
    builder = Builder::XmlMarkup.new
    message = builder.login("id" => login, "sid" => session_id, "gid" => group.id, "total" => group.loginusers + 1)
    send_xml_message message
  end  

  def send_logout_message(session_id)  
    # <logout id="unique_user_id" sid=["*"|"valid_user_session_id"] gid="id"/>
    builder = Builder::XmlMarkup.new
    # evitem que un missatge de logout extra (desde una tasca cron, feta a mà,..) envïi logout amb total < 0
    total = (group.loginusers == 0 ? 0 : group.loginusers - 1)
    message = builder.logout("id" => login, "sid" => session_id, "gid" => group.id, "total" => total)
    send_xml_message message
  end

  #   apps_to_be_added_to = [{:application => ApplicationObject, 
  #                           :parameters => {parameter_id => parameter_value, ...}},
  #                         ...]
  def adduser_message(apps_to_be_added_to=[], with_general=nil)
    # XML ADDUSER MESSAGE
    # <adduser id="unique_user_id" gid="id">
    #	<name>common name</name>
    #	<givenname>givenname</givenname>
    #	<surname>surname</surname>
    #	<email>email</email>
    #	<telephone>telephone</telephone>
    #	<mobile>mobile</mobile>
    #	<gid>id</gid>
    #	<applications>
    #	    <app id="application_id">
    #		<param name="parameter_name">parameter_value</param>
    #		...................... 
    #	   </app>
    #	   .......
    #	</applications>
    # </adduser>
    builder = Builder::XmlMarkup.new
    builder.adduser("id" => login, "gid" => group.id){
      #builder.givenname(login)
      builder.name(name)
      builder.surname(surname)
      builder.email(email)
      unless telephone == "": builder.telephone(telephone) end
      unless mobile == "": builder.mobile(mobile) end
      builder.applications {
        apps_to_be_added_to.each do |a|
          builder.app("id" => a[:application].unique_app_id) {
            a[:parameters].each_pair do |pid, pvalue|
              builder.param(pvalue, "name" => Parameter.find(pid).name)
            end
          }
        end

        if (with_general)
          builder.app("id" => "GENERAL") {
            builder.param(group.name, "name" => "groupname")
            builder.param(password_hash, "name" => "password")
            if role == "groupadmin" : builder.param("Admin", "name" => "role")   end
            if role == "user"       : builder.param("NoAdmin", "name" => "role") end
           }
        end
      }
    }
  end

  def deluser_message(apps_to_delete_from, with_general=nil)
    # XML DELUSER MESSAGE
    # <deluser id="unique_user_id">
    #   <gid>id</gid>
    #   <applications>
    #     <app id="application_id"/>
    #     ........
    #   </applications>
    # </deluser>
    builder = Builder::XmlMarkup.new
    builder.deluser("id" => login, :gid => group.id){
      builder.applications {
        apps_to_delete_from.each do |a|
          builder.app("id" => a.unique_app_id) 
        end

        if (with_general)
          builder.app("id" => "GENERAL")
        end
      }
    }
  end

  def self.find_all_by_group_and_application(group, application)
    users = []
    if application.users.size > 0
      users = self.find(:all, :conditions => [
        "id IN (?) AND group_id = ?", application.users.map{|u| u.id}, group.id])	
    end
    users  
  end

  def self.find_all_by_group_and_no_application(group, application)
  	if application.users.size == 0
  	  users = group.users
  	else  
      users = self.find(:all, :conditions => [
        "id NOT IN (?) AND group_id = ?", application.users.map{|u| u.id}, group.id])	
    end
    users    
  end

  # This method looks if the user has a setting for a given parameter, and
  # returns that setting. It works like this:
  # 1 -> Search in this user_settings for that parameter.
  # 2 -> If it finds nothing, search in this user's group settings for that
  #      parameter.
  # 3 -> If nothing was found, return the parameter default value      
  def find_user_setting_value(parameter)

    # Search for a user_setting for this parameter
    if user_setting = user_settings.find_by_parameter_id(parameter.id)
      return user_setting.value
    end

    # Search for a group_setting for this parameter
    value = nil
    if ['global', 'group'].include?(parameter.kind)
      if value = group.find_group_setting_value(parameter)
        return value
      end
    end
    
    # Search parameter default value
    return parameter.default_value

  end

  # Check if a user group is active (is client, admin, or in demo period).
  # Takes the user id as a parameter.
  def self.group_active?(user_login)
    u = find_by_login(user_login)
    u.nil? ? false : u.group.active?
  end

  def build_message_group_id groupname
    message_group_id = groupname.downcase
    if (message_group_id = message_group_id.delete(" ")) == nil
      message_group_id = groupname.downcase
    end
    message_group_id
  end

  #def build_message_app_id appname
  #  message_app_id = appname.upcase
  #  if (message_app_id = message_app_id.delete(" ")) == nil
  #    message_app_id = name.upcase
  #  end
  #  message_app_id
  #end

  # Apply SHA1 encryption to the supplied password. 
  # We will additionally surround the password with a salt 
  # for additional security. 
  def self.sha1(pass)
    Digest::SHA1.hexdigest("#{salt}--#{pass}--")
  end

  # Returns the base64 of the password
  def b64password
    Base64.encode64(plain_password)
  end

  # Returns the md5 hash of the password
  def md5password
    Digest::MD5.hexdigest(plain_password)
  end

  # Returns the md5 hash of the password
  def sha1password
    Digest::SHA1.hexdigest(plain_password)
  end

  # Returns the password encrypted (AES 256)
  def aes256password
     IO.popen("php #{RAILS_ROOT}/lib/php/aes256_enc.php #{plain_password}").readlines.join
  end

  def password=(pass)
    return if pass.blank?
    @password=pass
    self.plain_password = pass
    self.password_hash = User.sha1(pass)
  end

  # Returns a field value specifying the field as a string.
  # Ex: get_field_by_name("User.email")
  def get_field_by_name field
    self.send field.split(".")[1].to_sym
  end
 
  def root?
    role.split(" ").include?("privilegeduser") || role.split(" ").include?("platformadmin")
  end

  def groupadmin?
    role.split(" ").include?("groupadmin")
  end
   
  validates_uniqueness_of :login, :case_sensitive => false
  validates_presence_of :login
  validates_length_of   :login,:in => 3..40


  validates_confirmation_of :password,
                            :if => lambda { |user| user.new_record? or not user.password.blank? }
  validates_presence_of     :password, :password_confirmation,
                            :if => lambda { |user| user.new_record? or not user.password.blank? }
  validates_length_of       :password, :in => 5..40, 
                            :if => lambda { |user| user.new_record? or not user.password.blank? }
  def validate
    unless password.blank?
      users = User.find_all_by_group_id(group_id).reject!{|user| user.id == id }
      if users
        passwords = users.collect{ |user| user.plain_password }
        if passwords.include?(password)
          errors.add(:password, I18n.t("password_unique_in_group") )
        end
      end
    end
  end
  # -------------
  validates_presence_of :group_id, :role
  # name and surname are forced to login before validation if blank
  validates_presence_of :name
  validates_presence_of :surname
  
  validates_uniqueness_of :email, :unless => Proc.new { |user| user.email == Setting.unchecked_mail_address}
  validates_presence_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true
  
  validates_presence_of :telephone

  validates_format_of :login, :with => /^[0-9a-zA-Z]*$/
  validates_filesize_of :wallpaper, :in => 1.kilobytes..2048.kilobytes, :message => I18n.t("image_max_size")

  # Per ordenar els usuaris a la vista de l'administrador
  def group_created_at
    group.created_at
  end
  
end
