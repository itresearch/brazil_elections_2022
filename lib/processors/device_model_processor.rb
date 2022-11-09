require_relative "../common/constants.rb"

class DeviceModelProcessor

  MODEL_FIELD = "Modelo de Urna: "

  attr_reader :workspace, :tmp
  
  def initialize(workspace)
    @workspace = workspace
    @tmp = File.join(workspace, "tmp")
    FileUtils.mkdir_p(tmp)
  end

  def get_device_model_from_location(estado, cod_municipio, zona, secao, cod_turno)
    logs_downloader = LogsDownloader.new(workspace, estado, cod_municipio, zona, secao, cod_turno)
    logjez_file_path = logs_downloader.fetch_logs
    log_path = LogsDownloader.extract_logjez_file(logjez_file_path, tmp)

    get_device_model(log_path)
  end

  # Returns the device model given the *.logjez compressed file
  def get_device_model_from_zip(logjez_file)
    dest_path = LogsDownloader.extract_logjez_file(logjez_file, tmp)
    result = get_device_model(dest_path)

    File.delete(dest_path) if File.exist?(dest_path)

    result
  end

  # Returns the device model given the logd.dat log text file
  def get_device_model(log_file)
    return "-" unless File.exist?(log_file)

    File.open(log_file, encoding: ENCODING) do |file|
      line = file.find { |line| line.include?(MODEL_FIELD) }
      start_ix = line.index(MODEL_FIELD) + MODEL_FIELD.size
      line[start_ix..(line.index("\t", start_ix) - 1)]
    end
  end

end