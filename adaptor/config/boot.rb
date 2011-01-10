# Don't change this file. Configuration is done in config/environment.rb, config/environments/*.rb and settings.yml.

ADAPTOR_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(ADAPTOR_ROOT)

require 'rubygems'
require 'adaptation'

if defined? ADAPTOR_ENV
  require ADAPTOR_ROOT + '/config/environments/' + ADAPTOR_ENV + '.rb'
end
 
require ADAPTOR_ROOT + '/config/environment'
