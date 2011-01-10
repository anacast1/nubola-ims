require File.dirname(__FILE__) + '/../config/boot'

a =  Adaptation::Base.new
a.process ARGV[0] 
