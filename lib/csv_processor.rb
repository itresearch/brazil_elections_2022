require 'csv'
require_relative "common/constants.rb"
require_relative "processors/device_model_processor.rb"

class CsvProcessor
  attr_reader :workspace, :tmp
  
  def initialize(workspace)
    @workspace = workspace
    @tmp = File.join(workspace, "tmp")
    FileUtils.mkdir_p(tmp)
  end

  def enrich_csv_file(csv_path, dest_file)
    puts "\nProcessing #{csv_path}..."
    current_data = {}

    CSV.open(dest_file, "wb", encoding: ENCODING) do |csv|
      write_header(csv)
      total_locations = count_locations(csv_path)
      current_location_seq = 1

      CSV.foreach(csv_path, headers: true, col_sep: ";", quote_char: '"', liberal_parsing: true, encoding: ENCODING) do |row|
        pk = get_primary_key(row)

        if current_data[:pk] != nil && pk != current_data[:pk] && current_data["CD_CARGO_PERGUNTA"] == "1"
          # "CD_CARGO_PERGUNTA"] == "1" includes only votes for president
          current_location_seq += 1
          puts "processing SG_UF: #{current_data["SG_UF"]}, CD_MUNICIPIO: #{current_data["CD_MUNICIPIO"]}, NR_ZONA: #{current_data["NR_ZONA"]}, NR_SECAO: #{current_data["NR_SECAO"]} (#{current_location_seq} / #{total_locations})"
          write_row_to_csv(csv, current_data)
        end

        current_data[:pk] = pk

        current_data["NR_TURNO"] = row.field("NR_TURNO")
        current_data["SG_UF"] = row.field("SG_UF")
        current_data["CD_MUNICIPIO"] = row.field("CD_MUNICIPIO")
        current_data["NM_MUNICIPIO"] = row.field("NM_MUNICIPIO")
        current_data["NR_ZONA"] = row.field("NR_ZONA")
        current_data["NR_SECAO"] = row.field("NR_SECAO")
        current_data["CD_CARGO_PERGUNTA"] = row.field("CD_CARGO_PERGUNTA")
        current_data["QT_APTOS"] = row.field("QT_APTOS")
        current_data["QT_COMPARECIMENTO"] = row.field("QT_COMPARECIMENTO")
        current_data["QT_ABSTENCOES"] = row.field("QT_ABSTENCOES")
        current_data["CD_PLEITO"] = row.field("CD_PLEITO")
        
        vote_type = row.field("CD_TIPO_VOTAVEL")
        qtt_votes = row.field("QT_VOTOS")
        if vote_type == "1"
          # nominal
          current_data["QT_VOTOS_#{row.field("NR_VOTAVEL")}"] = qtt_votes
        elsif vote_type == "2"
          # branco
          current_data["QT_VOTOS_BRANCO"] = qtt_votes
        else
          # nulo
          current_data["QT_VOTOS_NULO"] = qtt_votes
        end
      end

      write_row_to_csv(csv, current_data)
    end
    puts "Finished writing csv to #{dest_file}"
  end

  private

  def write_header(csv)
    csv << ["NR_TURNO", "SG_UF", "CD_MUNICIPIO", "NM_MUNICIPIO", "NR_ZONA", "NR_SECAO", "CD_CARGO_PERGUNTA", "QT_APTOS", "QT_COMPARECIMENTO", "QT_ABSTENCOES", "CD_TIPO_VOTAVEL", "QT_VOTOS_BRANCO", "QT_VOTOS_NULO", "QT_VOTOS_13", "QT_VOTOS_22", "MODELO_URNA", "HORA_PRIMEIRO_VOTO", "HORA_ULTIMO_VOTO"]
  end

  def count_locations(csv_path)
    count = 0
    pk = ""
    CSV.foreach(csv_path, headers: true, col_sep: ";", quote_char: '"', liberal_parsing: true, encoding: ENCODING) do |row|
      new_pk = get_primary_key(row)
      count +=1 if pk != new_pk
      pk = new_pk
    end

    count
  end

  def get_primary_key(row)
    row.field("SG_UF") + row.field("CD_MUNICIPIO") + row.field("NR_ZONA") + row.field("NR_SECAO") + row.field("CD_CARGO_PERGUNTA")
  end

  def write_row_to_csv(csv, current_data)
    c = current_data

    logs_downloader = LogsDownloader.new(workspace, c["SG_UF"], c["CD_MUNICIPIO"], c["NR_ZONA"], c["NR_SECAO"], c["CD_PLEITO"])
    logjez_file_path = logs_downloader.fetch_logs
    log_path = LogsDownloader.extract_logjez_file(logjez_file_path, tmp)

    device_model = DeviceModelProcessor.new(workspace).get_device_model(log_path)
    vote_time_processor = VoteTimeProcessor.new
    vote_time_processor.process(log_path, COD_TURNO_DATA[c["CD_PLEITO"]])

    csv << [
      c["NR_TURNO"], 
      c["SG_UF"],
      c["CD_MUNICIPIO"],
      c["NM_MUNICIPIO"],
      c["NR_ZONA"],
      c["NR_SECAO"],
      c["CD_CARGO_PERGUNTA"],
      c["QT_APTOS"],
      c["QT_COMPARECIMENTO"],
      c["QT_ABSTENCOES"],
      c["CD_TIPO_VOTAVEL"],
      c["QT_VOTOS_BRANCO"],
      c["QT_VOTOS_NULO"],
      c["QT_VOTOS_13"],
      c["QT_VOTOS_22"],
      device_model,
      vote_time_processor.first_vote_at,
      vote_time_processor.last_vote_at,
    ]
  end
end