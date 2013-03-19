# Load the rails application
require File.expand_path('../application', __FILE__)

ENV['HOME'] ||= `echo ~`.strip
ENV['GEM_HOME'] = File.expand_path('~/.gems')
ENV['GEM_PATH'] = File.expand_path('~/.gems') + ":" + '/opt/ruby19/lib64/ruby/gems/1.9.1'

# Initialize the rails application
Moviedb::Application.initialize!