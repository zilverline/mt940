module MT940Structured
  class Parser
    def self.parse_mt940(path)
      file_content = FileContent.new(File.open(path).readlines.map { |line| line.encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace) })
      grouped_lines = file_content.group_lines
      file_content.get_header.parser.transform(grouped_lines)
    end

  end
end
