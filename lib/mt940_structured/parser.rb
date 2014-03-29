module MT940Structured
  class Parser
    def self.parse_mt940(path)
      file_content = FileContent.new(File.open(path).readlines.map do |line|
        line
        .encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace) # remove other obscure chars. god knows what people upload.
        .gsub(/\u001A/, '') # remove eof chars in the middle of the string... yes it happens :-(
      end)
      grouped_lines = file_content.group_lines
      file_content.get_header.parser.transform(grouped_lines)
    end
  end
end
