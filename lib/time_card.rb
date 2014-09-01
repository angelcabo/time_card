require 'active_record'
require 'yaml'
require 'time_card/version'
require 'time_card/dev_pair_parsing'
require 'time_card/queryable_on_mingle'
require 'time_card/report'
require 'time_card/time_segment'
require 'time_card/card'
require 'time_card/ove_card'
require 'time_card/ove_card_version'
require 'time_card/developer'

# noinspection RubyResolve
db_config = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection db_config
ActiveRecord::Base.logger = Logger.new(STDERR) if ENV['VERBOSE'] == 'true'

module TimeCard
end
