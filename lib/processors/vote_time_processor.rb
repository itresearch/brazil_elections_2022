require_relative "../common/constants.rb"

class VoteTimeProcessor
  VOTE_PATTERN = "Voto confirmado para [Presidente]"

  attr_reader :first_vote_at, :last_vote_at
  
  def process(log_file, date_str)
    return unless File.exist?(log_file)
    
    File.open(log_file, encoding: ENCODING) do |file|
      file.each_with_index do | line, index |
        next unless line.start_with?(date_str)

        is_vote = line_is_a_vote(line)
        @first_vote_at = get_time(line) if @first_vote_at.nil? && is_vote

        @last_vote_at = get_time(line) if is_vote
      end
    end
  end

  private 

  def get_time(line)
    line[11..18]
  end

  def line_is_a_vote(line)
    line.include?(VOTE_PATTERN)
  end
end