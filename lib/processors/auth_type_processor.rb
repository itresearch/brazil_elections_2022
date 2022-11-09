require_relative "../common/constants.rb"

class AuthTypeProcessor
  BIOMETRIC_PATTERN = "Tipo de habilitação do eleitor [biométrica]".encode(ENCODING)
  MANUAL_AUTH_PATTERN = "Solicitação de dado pessoal do eleitor para habilitação".encode(ENCODING)
  MANUAL_AUTH_PATTERN_2 = "O eleitor não possui biometria".encode(ENCODING)

  attr_reader :biometric_count, :manual_count

  def process(log_file, date_str)
    return unless File.exist?(log_file)

    @biometric_count = 0
    @manual_count = 0
    
    File.open(log_file, encoding: ENCODING) do |file|
      file.each_with_index do | line, index |
        next unless line.start_with?(date_str)

        @biometric_count += 1 if line.include?(BIOMETRIC_PATTERN)
        @manual_count += 1 if line.include?(MANUAL_AUTH_PATTERN) or line.include?(MANUAL_AUTH_PATTERN_2)
      end
    end
  end

end