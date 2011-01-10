require "fileutils"
include FileUtils

APP = "ims" # basename of the application
ENVI = "development"

cd "#{File.dirname(__FILE__)}"
t = Time.now
name = "#{APP}_#{ENVI}_#{t.day}_#{t.month}_#{t.year}_#{t.to_i}"
system("mysqldump -u root #{APP}_#{ENVI} > #{name}.sql")
system("tar cjf #{name}.tar.bz2 #{name}.sql")
rm_f("#{name}.sql")

