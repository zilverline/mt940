module MT940Structured
  class Parser
    def self.parse_mt940(path, join_lines_by = ' ')
      file_content = FileContent.new(readfile(path), join_lines_by)
      grouped_lines = file_content.group_lines
      parser = file_content.get_header.parser
      parser.transform(grouped_lines)
    end

    def self.bank_name(path, join_lines_by = ' ')
      file_content = FileContent.new(readfile(path), join_lines_by)
      file_content.get_header.parser.bank
    end

    def self.readfile(path)
      File.open(path).readlines.map do |line|
        line
          .encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace) # remove other obscure chars. god knows what people upload.
          .gsub(/\u001A/, '') # remove eof chars in the middle of the string... yes it happens :-(
      end
    end
  end
end
