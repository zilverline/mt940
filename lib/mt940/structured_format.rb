module MT940::StructuredFormat
  def parse_line
    super unless @skip_parse_line
  end

  def read_all_description_lines!
    @skip_parse_line = true
    index = @lines.index(@line)
    @lines[index+1..-1].each do |line|
      break if line.match MT940::Base::MT_940_TAG_LINE
      @transaction.description.lstrip!
      @transaction.description += line.gsub(/\n/, '').gsub(/>\d{2}\s*/, '').gsub(/\-XXX/, '').gsub(/-$/, '').strip
      @transaction.description.strip!
    end
  end
end
