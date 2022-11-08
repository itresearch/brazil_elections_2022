class LogsDownloader

  attr_reader :estado, :cod_municipio, :zona, :secao, :cod_turno, :workspace

  def initialize(workspace, estado, cod_municipio, zona, secao, cod_turno)
    @workspace = workspace
    @estado = estado.downcase
    @cod_municipio = "%05d" % cod_municipio
    @zona = "%04d" % zona
    @secao = "%04d" % secao
    @cod_turno = cod_turno
  end

  def fetch_logs
    logs_folder = File.join(workspace, "logs", estado, cod_municipio)
    FileUtils.mkdir_p(logs_folder)

    dest_path = File.join(logs_folder, "#{estado}-#{cod_municipio}-#{zona}-#{secao}-#{cod_turno}.logjez")

    download_logs(dest_path) unless File.exist?(dest_path)
    dest_path
  end

  def download_logs(dest_path)
    tmp_path = dest_path + ".tmp"
    hash = get_hash
    url = "https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/#{cod_turno}/dados/#{estado}/#{cod_municipio}/#{zona}/#{secao}/#{hash}/o00#{cod_turno}-#{cod_municipio}#{zona}#{secao}.logjez"
    File.delete(dest_path) if File.exist?(dest_path)
    File.delete(tmp_path) if File.exist?(tmp_path)
    File.open(tmp_path, "wb") do |file|
      file.binmode

      HTTParty.get(url, stream_body: true, headers: { "User-Agent" => "downloader" }) do |fragment|
        file.write(fragment)
      end
    end
    File.rename(tmp_path, dest_path)
    dest_path
  end

  private 

  def get_hash
    url = "https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/#{cod_turno}/dados/#{estado}/#{cod_municipio}/#{zona}/#{secao}/p000#{cod_turno}-#{estado}-m#{cod_municipio}-z#{zona}-s#{secao}-aux.json"

    resp = HTTParty.get(url, headers: { "User-Agent" => "downloader" })
    hashes = JSON.parse(resp.body)
    if hashes["hashes"].size != 1
      puts "*** WARN: #hashes != 1 (#{hashes["hashes"].size}). estado: #{estado}. cod_municipio: #{cod_municipio}. zona: #{zona}. secao: #{secao}. cod_turno: #{cod_turno}"
    end
    hashes["hashes"].first["hash"]
  rescue => e
    puts "[E] Error downloading hash. estado: #{estado}. cod_municipio: #{cod_municipio}. zona: #{zona}. secao: #{secao}. cod_turno: #{cod_turno}. Error: #{e}"
    "-"
  end
end