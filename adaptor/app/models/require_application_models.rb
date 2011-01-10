# alguns models necessiten RAILS_ROOT (per exemple Setting)
RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../application') unless defined?(RAILS_ROOT)

# requerit pels models que utilitzen file_column, que llencen excepcions Mysql
require 'mysql'
require File.join(File.dirname(__FILE__), '../../../application/vendor/plugins/file_column/lib/validations.rb')
ActiveRecord::Base.send(:include, FileColumn::Validations)

# requerit pels models que utilitzen MessageSender (per exemple User)
require File.join(File.dirname(__FILE__), '../../../application/lib/message_sender.rb')
Adaptation::Base.new
RAILS_DEFAULT_LOGGER = Adaptation::Base.logger

models_no_requerits = [
  "password_mailer.rb",       # requreix ActionMailer
  "confirmation_mailer.rb"    # idem
]

Dir[File.join(File.dirname(__FILE__), '../../../application/app/models/*.rb')].each do |f|
  require f unless models_no_requerits.include?(f.split('/').last)
end
