require "rspec/core/rake_task"
require_relative "lib/csv_downloader.rb"
require_relative "lib/csv_processor.rb"
require_relative "lib/device_model_collector.rb"
require_relative "lib/logs_downloader.rb"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :run do
  ruby 'lib/main.rb'
end

task :download_logs, [:estado, :municipio, :zona, :secao, :cod_turno, :dest_folder] do |task, args|
  file = File.join(args[:dest_folder], "#{args[:estado]}-#{"%05d" % args[:municipio]}-#{"%04d" % args[:zona]}-#{"%04d" % args[:secao]}-#{args[:cod_turno]}.logjez")
  LogsDownloader.new(args[:dest_folder], args[:estado], args[:municipio], args[:zona], args[:secao], args[:cod_turno]).download_logs(file)
  puts "Logs downloaded to #{file}"
end