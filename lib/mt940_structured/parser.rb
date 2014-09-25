
module MT940Structured
  class Parser
    def self.parse_mt940(path, join_lines_by = ' ')
      file_content = FileContent.new(readfile(File.open(path)), join_lines_by)
      grouped_lines = file_content.group_lines
      file_content.get_header.parser.transform(grouped_lines)
    end

    def self.parse_mt940_temp_file(stream, join_lines_by = ' ')
      file_content = FileContent.new(readfile(stream.tempfile.open), join_lines_by)
      grouped_lines = file_content.group_lines
      file_content.get_header.parser.transform(grouped_lines)
    end

    private
    def self.readfile(stringio)
      stringio.readlines.map do |line|
        line
          .encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace) # remove other obscure chars. god knows what people upload.
          .gsub(/\u001A/, '') # remove eof chars in the middle of the string... yes it happens :-(
      end
    end
  end
end
