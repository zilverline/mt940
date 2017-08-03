module MT940Structured::Parsers::Nedbank
  NEXT_LINES_FOR = {
    '20' => ['21','25','28'],
    '21' => ['25'],
    '28' => ['60'],
    '60' => ['61', '62'],
    '61' => ['61', '62', '86'],
    '62' => ['20'],
    '86' => ['20', '61', '62']
  }
  NO_NEXT_LINES = Set.new(['25', '64', '65'])
  class Parser < MT940Structured::Parsers::Base
    def initialize
      super "Nedbank", TransactionParsers.new, MT940Structured::Parsers::Nedbank::NEXT_LINES_FOR
    end

    protected
    def validate_grouped_lines(lines)
      lines.each_with_index do |current_line, index|
        if index < (lines.length - 1)
          next_line = lines[index+1]
          next_line_type = next_line[1,2]
          current_line_type = current_line[1, 2]
          next if NO_NEXT_LINES.include?(current_line_type)
          possible_next_line_starts = @next_lines_for[current_line_type]
          raise MT940Structured::InvalidFileContentError.new(%Q{Expected line of type #{possible_next_line_starts} after a #{current_line_type}, but was #{next_line_type}}) unless possible_next_line_starts.include?(next_line_type)
        end
      end
    end
  end

  class TransactionParsers

    def for_format(_)
      TransactionParser.new
    end
  end

end
