class MT940Structured::FileContent
  R_EOF_ING = /^-XXX$/
  R_EOF_ABN_AMRO = /^-$/
  R_EOF_TRIODOS = /^-$/

  def initialize(raw_lines, join_lines_by = "\n")
    @raw_lines = raw_lines
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
      mt940_line = line.match /^(:(?:20|25|28|60|61|86|62|64|65|86)[D|C|F|M]?:)/
      if mt940_line && previous_tag != $1
        previous_tag = $1
        grouped_lines << line
      else
        if line.match /^(:(?:20|25|28|60|61|86|62|64|65|86)[D|C|F|M]?:)(.*)/
          grouped_lines[-1] = [grouped_lines.last, @join_lines_by, $2].join
        else
          grouped_lines[-1] = [grouped_lines.last, '', line].join
        end
      end
    end
    grouped_lines
  rescue => e
    raise MT940Structured::InvalidFileContentError.new(e)
  end

  private

  def start_index
    @raw_lines.index { |line| line.match /^:20:/ }
  end

  def end_index
    return 0 unless check_eol_char?

    @raw_lines.rindex { |line| line.match(R_EOF_ING) || line.match(R_EOF_ABN_AMRO) ||line.match(R_EOF_TRIODOS) } || 0
  end

  def check_eol_char?
    %w(Ing Abnamro Triodos).include?(get_header.parser.bank)
  rescue
    true # if parsing the header fails then regard this as true
  end
end
