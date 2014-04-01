class MT940Structured::FileContent
  R_EOF_ING = /^-XXX$/
  R_EOF_ABN_AMRO = /^-$/
  R_EOF_TRIODOS = /^-$/

  def initialize(raw_lines, join_lines_by = ' ')
    @raw_lines = raw_lines.map{|line|line.strip}
    @join_lines_by = join_lines_by
  end

  def get_header
    MT940Structured::Header.new(@raw_lines)
  end

  def group_lines
    body_lines = @raw_lines[start_index..(end_index-1)]
    grouped_lines = []
    previous_tag = nil
    body_lines.each do |line|
      mt940_line = line.match /^(:\d{2}[D|C|F|M]?:)/
      if mt940_line && previous_tag != $1
        previous_tag = $1
        grouped_lines << line
      else
        next_line = if line.match /^(:\d{2}[D|C|F|M]?:)(.*)/
                      $2
                    else
                      line
                    end
        grouped_lines[-1] = [grouped_lines.last, @join_lines_by, next_line].join
      end
    end
    grouped_lines
  end

  private

  def start_index
    @raw_lines.index { |line| line.match /^:20:/ }
  end

  def end_index
    @raw_lines.rindex { |line| line.match(R_EOF_ING) || line.match(R_EOF_ABN_AMRO) ||line.match(R_EOF_TRIODOS) } || 0
  end

end
