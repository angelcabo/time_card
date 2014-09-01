require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'time_card'
require 'csv'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Print out summary of card work for a given time range with developer names and initiative names for each card'
task :show_work_summary_for_week, :output_file, :start_date, :end_date do |_, args|
  args.with_defaults(:start_date => Date.today - (Date.today.wday + 7), :end_date => Date.today - (Date.today.wday + 1))
  puts "Fetching summary of work done between #{args[:start_date]} and #{args[:end_date]}\n==========================="
  report = TimeCard::Report.new card_klass: TimeCard::OveCard, start_date: args[:start_date], end_date: args[:end_date]
  summary = report.card_work_summary
  puts summary

  if args[:output_file]
    File.open(args[:output_file], 'w') do |f|
      f.write summary.to_json
    end
  end
end

desc 'Run work breakdown report. Dates default to last Sunday - Saturday. (e.g. reports/input.json,reports/output.txt,2014-08-17,2014-08-23)'
task :run_report, :processed_summary_file, :output_file, :start_date, :end_date do |_, args|
  args.with_defaults(:start_date => Date.today - (Date.today.wday + 7), :end_date => Date.today - (Date.today.wday + 1))
  puts "Fetching summary of work done between #{args[:start_date]} and #{args[:end_date]}\n==========================="
  report = TimeCard::Report.new card_klass: TimeCard::OveCard,
                                card_data_file: args[:processed_summary_file],
                                start_date: args[:start_date],
                                end_date: args[:end_date]
  cards = report.card_work_summary
  developers = report.all_developers(cards).map { |dev| TimeCard::Developer.new dev }
  initiative_breakdown = report.work_breakdown_for_developers developers, cards
  total_time = initiative_breakdown.map { |info| info[:hours] }.reduce(:+).to_f
  time_data = initiative_breakdown.group_by { |info| info[:oracle_code] }.map do |code, info|
    [code, (info.map{|i| i[:hours]}.reduce(:+).to_f / total_time * 40).round(2)]
  end
  puts time_data

  if args[:output_file]
    File.open(args[:output_file], 'w') do |file|
      time_data.each do |info|
        initiative_card = TimeCard::OveCard.where(cp_oracle_code: info[0]).first
        file.puts "#{info[0]}: #{info[1]} #{initiative_card.name}"
      end
    end
  end
end

desc 'Dump mingle card data for a given time range to a file.'
task :dump_mingle_card_data_for_week, :file, :start_date, :end_date do |_, args|
  args.with_defaults(:start_date => Date.today - (Date.today.wday + 7), :end_date => Date.today - (Date.today.wday + 1), :file => 'mingle_data.yml')
  data = TimeCard::OveCard.find_all_in_time_range args[:start_date], args[:end_date]
  File.open(args[:file], 'w') do |file|
    file.write data.to_yaml
  end
end

desc 'Print all initiatives in Mingle.'
task :show_all_app_initiatives, :file do |_, args|
  args.with_defaults(:file => 'reports/ove_initiatives.json')
  report = TimeCard::Report.new card_klass: TimeCard::OveCard
  initiatives = report.find_all_initiatives.map{|i| {id: i.id, number: i.number, name: i.name, otl_code: i.cp_oracle_code} }

  File.open(args[:file], 'w') do |f|
    f.write initiatives.to_json
  end
end

desc 'Dump mingle card table schema for testing and/or local DB setup.'
task :dump_mingle_table_schemas_for_local_db, :file do |_, args|
  args.with_defaults(:file => 'spec/support/schema.rb')
  db_config = YAML::load(File.expand_path('database.yml', File.dirname(__FILE__)) )
  stream = StringIO.new
  ActiveRecord::Base.establish_connection db_config
  ActiveRecord::SchemaDumper.ignore_tables = [/^(?!ove_2_card)\w+$/]
  ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)

  output = stream.string

  File.open(args[:file], 'w') do |file|
    file.write output
  end
end

desc 'Dump mingle card data, specified by ID, to a file.'
task :dump_mingle_card_by_id_to_file, :id, :file do |_, args|
  args.with_defaults(:file => 'spec/fixtures/time_card.yml')
  raise 'Missing Card ID' unless args[:id]
  card = TimeCard::OveCard.find args[:id]

  File.open(args[:file], 'a') do |file|
    file.write card.to_yaml
  end
end