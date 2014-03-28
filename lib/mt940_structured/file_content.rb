class MT940Structured::FileContent
  R_EOF_ING = /^-XXX$/
  R_EOF_ABN_AMRO = /^-$/
  R_EOF_TRIODOS = /^-$/

  def initialize(raw_lines)
    @raw_lines = raw_lines
  end

  def get_header
    MT940Structured::Header.new(@raw_lines)
  end

  def group_lines
    body_lines = @raw_lines[start_index..(end_index-1)]
    grouped_lines = []
    body_lines.each do |line|
      if line.match /^:\d{2}(D|C|F)?:/
        grouped_lines << line
      else
        grouped_lines[-1] = "#{grouped_lines.last}#{line}"
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
