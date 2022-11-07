require_relative "csv_downloader.rb"
require_relative "csv_processor.rb"
require_relative "device_model_collector.rb"
require_relative "logs_downloader.rb"

workspace = File.join(ENV["HOME"], "elections_data")

downloader = CsvDownloader.new(workspace)
downloader.download_csvs

csv_files = Dir[File.join(workspace, "*.csv")]
csv_files.each do |path|
  filename = File.basename(path, ".*") 
  dest_folder = File.join(workspace, "processed")
  dest_file = File.join(dest_folder, "#{filename}-processed.csv")
  puts "\n\n=== PROCESSING state #{path} to #{dest_file}"
  CsvProcessor.new(workspace).enrich_csv_file(path, dest_file)
end