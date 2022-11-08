require "fileutils"
require "httparty"
require "zip"
require_relative "common/constants.rb"

class CsvDownloader
  attr_reader :workspace, :tmp
  
  def initialize(workspace)
    @workspace = workspace
    @tmp = File.join(workspace, "tmp")
    FileUtils.mkdir_p(tmp)
  end

  # Downloads the voting summary csv for all Brazil's States and stores them in the workspace folder
  def download_csvs
    puts "Downloading csv files..."
    STATES.each do |state|
      url = "https://cdn.tse.jus.br/estatistica/sead/eleicoes/eleicoes2022/buweb/bweb_2t_#{state}_311020221535.zip"

      zip_file = File.join(tmp, "#{state}.zip")
      next if File.exist?(zip_file)

      puts "Downloading #{state} file to #{zip_file}"

      File.open(zip_file, "w") do |file|
        file.binmode

        HTTParty.get(url, stream_body: true, headers: { "User-Agent" => "downloader" }) do |fragment|
          file.write(fragment)
        end
      end
      dest_file = File.join(workspace, "#{state.downcase}.csv")
      unzip_csv_file(zip_file, dest_file)
    end
  end

  private

  def unzip_csv_file(zip_path, dest_path)
    Zip::File.open(zip_path) do |zip_file|
      entry = zip_file.glob('*.csv').first
      
      File.delete(dest_path) if File.exist?(dest_path)
      zip_file.extract(entry, dest_path)
    end
  end
end
